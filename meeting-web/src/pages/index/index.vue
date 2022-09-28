<template>
  <div class="nemeeting-index">
    <header></header>
    <section>
      <router-view></router-view>
    </section>
    <footer></footer>
  </div>
</template>

<script lang="ts">
import Vue from 'vue'
export default Vue.extend({
  name: 'nemeeting-index',
})
</script>

<style lang="stylus">
.nemeeting-index
  width 100%
  height 100%
  display flex
  flex-direction column
  section
    flex-grow 1
    display flex
    justify-content center
    align-items center
</style>
