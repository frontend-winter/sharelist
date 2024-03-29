<template>
  <n-config-provider :theme="isDarkTheme ? darkTheme : ''">
    <Index :isDarkTheme="isDarkTheme" @changeIsDarkTheme="changeIsDarkTheme" />
  </n-config-provider>
</template>

<script>
import { defineComponent } from 'vue'
import { darkTheme } from 'naive-ui'
import Index from './components/index.vue'
export default defineComponent({
  components: {
    Index
  },
  setup() {
    const KEY = 'isDarkTheme';
    const localDarkTheme = localStorage.getItem(KEY);

    // 默认为黑色主题
    const isDarkTheme = ref(localDarkTheme === 'true');
    const changeIsDarkTheme = (v) => {
      isDarkTheme.value = v;
      localStorage.setItem(KEY, v);
    }
    return {
      darkTheme,
      isDarkTheme,
      changeIsDarkTheme
    }
  }
})
</script>
