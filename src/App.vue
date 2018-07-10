<template>
  <div id="app">
    <router-view></router-view>
  </div>
</template>

<script>
import WarriorBase from '@/js/warriorBase'
import LordBase from '@/js/lordBase'
import Database from '@/js/database'

export default {
  name: 'app',


  beforeCreate: function () {
    WarriorBase.init().then(() => {
      console.log('WarriorBase初始化成功')
      LordBase.init().then(() => {
        console.log('LordBase初始化成功')
        Database.init().then(() => {
          console.log('Database初始化成功')
        })
      }).catch(err => {
        console.log(err)
      })
    }).catch(err => {
      console.log(err)
    })
  }
}
</script>

<style>
*{
  margin: 0;
  padding: 0;
}
body,html{
  width: 100%;
  height: 100%;
  /* background: rgba(7,17,27,0.96); */
}
a {
  text-decoration: none;
  /* color: #333; */
}
#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  width: 100%;
  height: 100%;
}

.fade-out-enter-active, .fade-out-leave-active {
    transition: all .5s
}
.fade-out-enter, .fade-out-leave-active {
    opacity: 0;
    transform: translateX(-400px);
} 

</style>
