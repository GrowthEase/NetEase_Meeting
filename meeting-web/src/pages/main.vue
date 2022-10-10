<!--
 * @Description: 对外站点主入口文件
-->
<template>
  <div class="nemeeting-main">
    <router-view></router-view>
  </div>
</template>

<script>
import '../reset.css'
export default {
  name: 'website-main',
}
</script>

<style lang="stylus">
.nemeeting-main
  width 100%
  height 100vh
</style>
