<template>
  <a href="https://github.com/frontend-winter/sharelist" class="github-link" target="_blank" style="width: 48px; height: 48px;">
    <img src="@/assets/GitHub-Mark-ea2971cee799.png" alt="GitHub" width="100%" style="border-radius: 50%">
  </a>
</template>

<script>
export default {
  name: 'GitHubCorner'
}
</script>

<style scoped>
.github-link {
  position: fixed;
  top: 10px;      /* 可以根据需要调整边距 */
  right: 10px;    /* 可以根据需要调整边距 */
  z-index: 1000;  /* 确保链接在最上层 */
}

</style>
