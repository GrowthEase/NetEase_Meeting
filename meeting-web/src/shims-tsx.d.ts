import Vue, { VNode } from 'vue'

declare global {
  namespace JSX {
    // tslint:disable no-empty-interface
    // @ts-ignore
    // type Element = VNode
    // tslint:disable no-empty-interface
    // @ts-ignore
    // type ElementClass = Vue
    interface IntrinsicElements {
      [elem: string]: any
    }
  }
}
