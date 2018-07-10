import Vue from 'vue'
import Router from 'vue-router'
import Dashboard from '@/components/Dashboard'

import Adopt from '@/components/Adopt'
import Fight from '@/components/Fight'
import MyWarrior from '@/components/MyWarrior'



Vue.use(Router)

export default new Router({
  routes: [
    {
      path: '/',
      component: Dashboard
    },

    {
      path: '/dashboard',
      component: Dashboard,
      // children : [{
      //   path : '/customer-login',
      //   // 懒加载
      //   component : resolve => require(['@/components/Collect.vue'],resolve)
      // },{
      //   path : '/admin-login',
      //   // 懒加载
      //   component : resolve => require(['@/components/Collect.vue'],resolve)
      // }]
    },

    {
      path: '/adopt',
      name: 'adopt',
      component: Adopt
	  },
	
	  {
		path: '/fight',
		name: 'fight',
		component: Fight
    },
    
    {
      path: '/myWarrior',
      name: 'myWarrior',
      component: MyWarrior
    },


  ]
})
