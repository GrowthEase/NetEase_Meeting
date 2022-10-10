<template>
  <div class="v-form">
    <form>
      <slot></slot>
    </form>
  </div>
</template>

<script>
import AsyncValidator from 'async-validator'
import Vue from 'vue'

export default Vue.extend({
  name: 'v-form',
  componentName: 'VForm',
  props: {
    model: Object,
    rules: Object,
    labelWidth: String,
    errSite: {
      type: String,
      default: 'bottom',
    },
  },
  provide() {
    return {
      VForm: this,
    }
  },
  data() {
    return {
      fields: [], // field: {prop, el}，保存 FormItem 的信息。
      formError: {},
    }
  },
  computed: {
    formRules() {
      const descriptor = {}
      this.fields.forEach(({ prop }) => {
        if (!Array.isArray(this.rules[prop])) {
          console.warn(
            `prop 为 ${prop} 的 FormItem 校验规则不存在或者其值不是数组`
          )
          descriptor[prop] = [{ required: true }]
          return
        }
        descriptor[prop] = this.rules[prop]
      })
      return descriptor
    },
    formValues() {
      return this.fields.reduce((data, { prop }) => {
        data[prop] = this.model[prop]
        return data
      }, {})
    },
  },
  methods: {
    validate(callback) {
      const validator = new AsyncValidator(this.formRules)
      validator.validate(this.formValues, (errors) => {
        let formError = {}
        if (errors && errors.length) {
          errors.forEach(({ message, field }) => {
            formError[field] = message
          })
        } else {
          formError = {}
        }
        this.formError = formError
        // 让错误信息的顺序与表单组件的顺序相同
        const errInfo = []
        this.fields.forEach(({ prop }) => {
          if (formError[prop]) {
            errInfo.push(formError[prop])
          }
        })
        if (errInfo.length === 0) {
          callback(null)
          return true
        }
        callback(errInfo)
      })
    },
  },
  created() {
    this.$on('form.addField', (field) => {
      if (field) {
        this.fields = [...this.fields, field]
      }
    })
    this.$on('form.removeField', (field) => {
      if (field) {
        this.fields = this.fields.filter(({ prop }) => prop !== field.prop)
      }
    })
  },
})
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style lang="stylus"></style>
