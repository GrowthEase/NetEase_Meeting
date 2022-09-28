<template>
  <div class="v-form-item">
    <label
      :for="prop"
      class="v-form-item-label"
      v-if="label"
      :style="labelStyle"
    >
      {{ label }}
    </label>
    <div class="v-form-item-content">
      <div :class="`content ${errSite}`">
        <slot></slot>
        <p v-if="hint" class="hint">{{ hint }}</p>
        <transition name="fade">
          <p
            v-if="fieldError && errSite === 'bottom'"
            style="animation-duration: 0.2s"
            :class="`error-message ${errSite}`"
          >
            {{ fieldError }}
          </p>
        </transition>
      </div>
      <transition name="fade">
        <p
          v-if="fieldError && errSite === 'right'"
          style="animation-duration: 0.2s"
          :class="`error-message ${errSite}`"
        >
          {{ fieldError }}
        </p>
      </transition>
    </div>
  </div>
</template>
<script>
import AsyncValidator from 'async-validator'
import Vue from 'vue'
import 'vue2-animate/dist/vue2-animate.min.css'

export default Vue.extend({
  name: 'v-form-item',
  componentName: 'VFormItem',
  data() {
    return {
      validateMessage: null,
    }
  },
  provide() {
    return {
      VFormItem: this,
    }
  },
  inject: ['VForm'],
  computed: {
    errSite() {
      return this.form.errSite
    },
    form() {
      let parent = this.$parent
      while (parent.$options.componentName !== 'VForm') {
        parent = parent.$parent
      }
      return parent
    },
    fieldError() {
      if (!this.prop) {
        return ''
      }
      const formError = this.form.formError
      return formError[this.prop]
    },
    labelStyle() {
      const ret = {}
      const labelWidth = this.labelWidth || this.form.labelWidth
      if (labelWidth) {
        ret.width = labelWidth
      }
      return ret
    },
    fieldValue() {
      const model = this.form.model
      if (!model || !this.prop) {
        return
      }
      let path = this.prop
      if (path.indexOf(':') !== -1) {
        path = path.replace(/:/, '.')
      }
      return model[this.prop]
    },
  },
  methods: {
    validate(trigger) {
      const model = {}
      model[this.prop] = this.fieldValue
      const rules = {}
      rules[this.prop] = this.form.formRules[this.prop]
      if (rules[this.prop].some((item) => item.trigger === trigger)) {
        const validator = new AsyncValidator(rules)
        validator.validate(model, (errors) => {
          if (errors && errors.length > 0) {
            this.$set(this.form.formError, this.prop, errors[0].message)
          } else {
            this.$set(this.form.formError, this.prop, '')
          }
        })
      }
    },
    onFieldChange() {
      this.validate('change')
    },
    dispatchEvent(eventName, params) {
      if (typeof this.form !== 'object' && !this.form.$emit) {
        console.error('FormItem必须在Form组件内')
        return
      }
      this.form.$emit(eventName, params)
    },
  },
  props: {
    prop: String,
    label: String,
    labelWidth: String,
    hint: String,
  },
  mounted() {
    if (this.prop) {
      this.dispatchEvent('form.addField', {
        prop: this.prop,
        el: this.$el,
      })
      this.$on('form.change', this.onFieldChange)
    }
  },
  beforeDestroy() {
    if (this.prop) {
      this.dispatchEvent('form.removeField', {
        prop: this.prop,
      })
    }
  },
})
</script>
<style lang="stylus">
.v-form-item
  display flex
  font-size 14px
  align-items baseline
  & .v-form-item-label
    width 80px
    padding 0 10px 0 0
    text-align right
  & .v-form-item-content
    position relative
    flex 1
    & .content
      position relative
      display flex
      align-items center
      padding 0 0 22px 0
      flex-wrap wrap
    & .hint
      margin 4px 0 6px
      color #AAA
      font-size 0.75rem
    & .error-message
      position absolute
      bottom 2px
      left 0
      height 20px
      line-height 20px
      font-size 0.75rem
      color red
      &.right
        right 0
        width 40%
        left 65%
        top 15%
    & .content
      &.right
        width 60%
</style>
