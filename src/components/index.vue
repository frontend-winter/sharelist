<template>
  <n-global-style />
  <n-grid class="notice" x-gap="12" :cols="1" :style="theme()">
    <n-gi>
      <div style="display: flex;flex-direction: row-reverse;margin: 10px 10px 0 0;">
        <n-switch :default-value="isDarkTheme" @update:value="(v) => $emit('changeIsDarkTheme', v)" >
          <template #checked-icon>
            <DarkModeOutlined />
          </template>
          <template #unchecked-icon>
            <DarkModeTwotone />
          </template>
        </n-switch>
      </div>
      <div class="light-green" v-html="notice"></div>
    </n-gi>
  </n-grid>
  <n-grid x-gap="10" y-gap="10" cols="2 s:3 m:4 l:5 xl:5 2xl:6" responsive="screen">
    <n-grid-item class="cardclss" v-for="item in itemslist" :key="item.carID" :style="theme()">
      <n-card size="small" bordered="false" content-style="box-class" content-class="box-class"
              @click="redirectTo(item.carID)">
        <div style="display: flex;align-items: center;justify-content: space-between;">
          <div style="display: flex;align-items: center;">
            <n-button text-color="white" :color="item.isPlus === 0 ? '#19c37d' : '#ab68ff'" type="tertiary"
                      size="small">
              {{ item.label }}
            </n-button>

            <n-button v-if="item.label.toLowerCase() === 'plus' && item.carID.toLowerCase().startsWith('t')"
                      text-color="white" :color="'#68bceb'" type="tertiary" size="small" style="margin-left: 4px">
              TEAM
            </n-button>
          </div>
          <n-text class="title">{{ item.carID }}</n-text>
        </div>

        <div class="message-with-dot" :style="{ '--dot-color': customColor(item.color) }">
          状态：{{ item.message?.replaceAll('空闲|', '')?.replaceAll('繁忙|', '') }}
        </div>

      </n-card>
    </n-grid-item>
  </n-grid>

  <n-divider dashed title-placement="center" style="font-size: 14px" v-if="itemslist.length < total">
    上拉加载更多
  </n-divider>


</template>
<script lang="ts">

function uniqueArrayObjects(arr) {
  const jsonObjectSet = new Set();
  const uniqueArray = [];

  arr.forEach(item => {
    const jsonString = JSON.stringify(item);
    if (!jsonObjectSet.has(jsonString)) {
      jsonObjectSet.add(jsonString);
      uniqueArray.push(item);
    }
  });

  return uniqueArray;
}

const isDev = import.meta.env.MODE === 'development'

import axios from 'axios';
import { DarkModeTwotone, DarkModeOutlined } from '@vicons/material'
import { useLoadingBar } from 'naive-ui'
export default {
  props: {
    isDarkTheme: {
      type: Boolean,
      default: false
    }
  },
  components: {
    DarkModeTwotone,
    DarkModeOutlined
  },
  data() {
    return {
      itemslist: [],
      itemsplus: [],
      notice: "",
      total: 0,
      page: 1,
      isLoading: false,
      hasMoreData: true,
      minPage: 50,
      loadingBar: null
    };
  },
  mounted() {
    this.fetchData();
    window.addEventListener('scroll', this.handleScroll);
    document.addEventListener('visibilitychange', this.handleVisibilityChange);
  },

  beforeDestroy() {
    document.removeEventListener('visibilitychange', this.handleVisibilityChange);
  },

  methods: {
    handleVisibilityChange() {
      if (!document.hidden) {
        /**
         * 3-27：强制更新
         * 3-30： 关闭，太费带宽
         */
        // this.updateEndpointStatus(this.itemslist, true)
      }
    },
    async updateEndpointStatus(list, forkUpdate = false) {
      try {
        let baseUrl = isDev ? '/api' : '';
        let promises = list.map(item => {
          let carname = encodeURIComponent(`${item.carID}`);
          let requestUrl = `${baseUrl}/endpoint?carid=${carname}`;
          return fetch(requestUrl)
            .then(response => response.json())
            .then(data => {
              return { ...item, ...data };
            })
            .catch(error => {
              console.error('Error fetching icon data:', error);
              return item; // 发生错误时返回未修改的 item
            });
        });
        return Promise.all(promises).then(newItems => {
          if (forkUpdate) {
            this.itemslist = uniqueArrayObjects(newItems);
          } else {
            this.itemslist = uniqueArrayObjects([...this.itemslist, ...newItems]);
          }
        });
      } catch (e) {
        console.error('请求错误:', e);
      }
    },
    theme() {
      return this.isDarkTheme ? { 'background-color': '#252529' } : { 'background-color': '#eff4f9' }
    },
    customColor(c) {
      return c === 'yellow' ? '#ffc70b' : c;
    },
    fetchData() {
      if (!this.hasMoreData || this.isLoading) return; // 如果没有更多数据或正在加载，则不执行任何操作

      if (!this.loadingBar) {
        this.loadingBar = useLoadingBar();
      }
      this.loadingBar.start()

      this.isLoading = true;
      axios.post(isDev ? '/api/carpage' : '/carpage', {
        page: this.page,
        size: this.minPage
      })
        .then(async response => {
          if (response.data.data.list === null) {
            this.hasMoreData = false;
            return;
          }
          this.notice = response.data.notice;
          this.total = response.data?.data?.pagination?.total ?? 0;

          this.page += 1;
          await this.updateEndpointStatus(response.data?.data?.list);
          this.loadingBar.finish()
        })
        .catch(error => {
          console.error('请求错误:', error);
          this.loadingBar.error()
        })
        .finally(() => {
          this.isLoading = false;

          this.loadingBar.finish()
        });
    },
    handleScroll() {
      const nearBottomOfPage = window.innerHeight + window.scrollY >= document.body.offsetHeight - 100;
      if (nearBottomOfPage && !this.isLoading) {
        // console.log('handleScroll')
        this.fetchData();
      }
    },
    redirectTo(carID) {
      window.location.href = `${window.location.origin
      }/auth/login?carid=${encodeURI(carID)}`;
    },
    beforeDestroy() {
      window.removeEventListener('scroll', this.handleScroll);
    }
  }
};

</script>



<style>
#app {
  padding: 10px;
}

.n-button {
  border-radius: 7px;
}

.n-gradient-text {
  margin-top: 10px;
}

.message-with-dot {
  margin-top: 10px;
  position: relative;
  padding-left: 20px;
  color: gray;
  font-size: 12px;
}

.message-with-dot:before {
  content: '';
  position: absolute;
  left: 0;
  top: 50%;
  transform: translateY(-50%);
  width: 12px;
  height: 12px;
  border-radius: 50%;
  background: var(--dot-color);
  border: 1px #e7eeed solid;
}


.box-class {
  border-radius: 10px !important;

}

.box-class .status {
  margin-top: 10px;
}

.box-class:hover {
  box-shadow: 0px 4px 6px rgba(0, 0, 0, 0.1);
}

.n-button {
  width: 50px;
  height: 20px;
  line-height: 20px;
  font-size: 10px;
}

.n-button span {
  font-weight: 800;
}

.cardclss .title {
  font-weight: 600;
  margin-left: 5px;
}

.notice {
  /*color: #67c23a;*/
  border-radius: 10px !important;
  margin-bottom: 20px;
}

.light-green {
  padding: 0 20px 20px 20px;
  border-radius: 10px;
  background: none;
}

.cardclss {
  border-radius: 10px !important;
}

.n-card {
  height: 100% !important;
  width: 100% !important;
}

.n-card:hover {
  cursor: pointer;
}

.cardclss .n-card {
  border: 0 !important;
  color: black;
  text-align: left;
  --n-close-border-radius: 10px !important;
  background: none;
}
</style>
