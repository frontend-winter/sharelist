<template>
  <n-modal :show="showModal">
    <n-card
      style="width: 500px"
      title="PleaseEnterUserToken"
      :bordered="false"
      size="huge"
      role="dialog"
      aria-modal="true"
    >
      <template #header-extra>
        <div style="width: 20px; display: flex; align-items: center; cursor: pointer" @click="$emit('changeShowModal', false)">
          <CloseFullscreenSharp />
        </div>
      </template>
      <n-form
        ref="formRef"
        inline
        label-placement="left"
        label-width="auto"
        :model="formValue"
      >
        <n-form-item label="UserToken" path="password"  style="width: 100%">
          <n-input type="password" v-model:value="formValue.password" placeholder="PleaseEnterUserToken" />
        </n-form-item>
      </n-form>
      <template #footer>
        <n-space reverse>
          <n-button type="success" size="small" @click="Confirm">
            Confirm
          </n-button>
          <n-button size="small" @click="$emit('changeShowModal', false)">
            Cancel
          </n-button>
        </n-space>
      </template>
    </n-card>
  </n-modal>
</template>

<script lang="ts">

import { CloseFullscreenSharp } from '@vicons/material'
import { setCookie, BASE_PASSWORD_KEY } from '../lib/Cookies'
export default {
  props: {
    showModal: {
      type: Boolean,
      default: false
    }
  },
  components: {
    CloseFullscreenSharp
  },
  data() {
    return {
      formValue:{
        password: ''
      },
    }
  },
  methods: {
    Confirm() {
      if (!this.formValue.password) return;
      setCookie(BASE_PASSWORD_KEY, this.formValue.password, 7);
      this.$emit('changeShowModal', false);
      this.$emit('changeConfig', this.formValue.password);
    }
  }
}
</script>
