<template>

  <div id="fight">
    <div class="TopBar">
      <mu-appbar>
          <mu-icon-button icon="menu" slot="left" @click = "toggle()"/>
          <span>战斗</span>
          <span class="curAddr">Account {{ curAddr }}</span>
          <span class="choiceId"> </span>

      </mu-appbar>
    </div>
  
    <div>
      
      <!-- <mu-raised-button label="toggle drawer" @click="toggle()"/> -->
      <mu-drawer :open="open" :docked="docked" @close="toggle()">
      <div class = "avatarTop">
        <mu-avatar slot = "left" :src="rolePic" :size="100"/>
      </div>

      <div class="avatarBottom">
        <span>Account Value {{ accountDetail.accountValue }} Ether</span>
      </div>

        <mu-list @itemClick="docked ? '' : toggle()">

          <mu-list-item title="旅行" @click="routerToTravel">
            <mu-icon slot="left"
               value="commute"
               color="#2e2c6b" />
          </mu-list-item>

          <mu-list-item title="我的角斗士" @click="routerToMyWarrior">
            <mu-icon slot="left"
               value="work"
               color="#2e2c6b" />
          </mu-list-item>

          <mu-list-item title="装备" @click="routerToWeapon">
            <mu-icon slot="left"
               value="colorize"
               color="#2e2c6b" />
          </mu-list-item>

          <mu-list-item title="活动" @click="routerToActivity">
            <mu-icon slot="left"            
               value="local_activity"
               color="#2e2c6b" />
          </mu-list-item>

          <mu-list-item title="战斗" @click="routerToFight">
            <mu-icon slot="left"
               value="add_shopping_cart"
               color="#2e2c6b" />
          </mu-list-item>

          <mu-list-item title="收养" @click="routerToAdopt">
            <mu-icon slot="left"
               value="build"
               color="#2e2c6b" />
          </mu-list-item>

          <mu-list-item v-if="docked" @click.native="open = false" title="关闭">
            <mu-icon slot="left"
               value="close"
               color="#2e2c6b" />
          </mu-list-item>
        </mu-list>
      </mu-drawer>
    </div>

    <div style="position: relative;top: 80px; margin-left: -200%;">
      <h1>Your Chosen Gladiator</h1>
      <div v-if="NotHasChosen">
        <p>You have not choesn a gladiator to fight for you!</p>
      </div>
      <div v-else >
        <h2>ID {{chosenToken.id}}</h2>
        <h2>win {{chosenToken.winCount}}</h2>
        <h2>title {{chosenToken.title}}</h2>
        <h2>loss {{chosenToken.lossCount}}</h2>
        <h2>prestige {{chosenToken.prestige}}</h2>
        <h2>combo {{chosenToken.combo}}</h2>
        <h2>CE {{chosenToken.CE}}</h2>
        <h2>status {{ chosenToken.status }}</h2>
      </div>
    </div>


    <div style="position: relative;top: -200px; ">
      <el-row >
        <el-col :span="4" v-for="enemy in enemylist" :key="enemy.id" :offset="3" style="margin-bottom:40px">
          <el-card :body-style="{ padding: '0px', height:'360px'}" shadow="hover" style="width: 260px;height: 350px;">
            <div style="padding: 6px;height: 310px;">
              <div>
                  <!-- <div><font size="5">{{enemy.pcname}}</font></div>
                  <div style="position: relative;top: 15px;text-align: center;">{{enemy.pname}}</div> -->
              </div>
              <div style="position: relative;top: 15px;left:0">
                  <img src="/static/warrior.png" class="image">
                  <!-- <div style="position: relative;top: 10px;left: 66px;"><i class="el-icon-time"></i>{{enemy.pdatesave}}</div> -->
              </div>
              <div style="position: relative;top: 5px;">
                  <!-- <i class="el-icon-view" style="position:relative;left:-80px;"></i> -->
                  <div>
                    <span style="position:relative;left:-30px;">ID {{enemy.id}}</span>
                    <span style="position:relative;left:20px;">Percentage {{enemy.winningPercentage}}%</span>
                    
                    <!-- <span style="position:relative; left:20px;">Value {{enemy.val}}</span> -->
                  </div>
                  <div>
                    <span style="position:relative;left:-35px;">win {{enemy.winCount}}</span>
                    <span style="position:relative;left: 20px;">title {{enemy.title}}</span>
                  </div>
                  <div>
                    <span style="position:relative;left:-55px;">loss {{enemy.lossCount}}</span>
                    <span style="position:relative;left:20px;">prestige {{enemy.prestige}}</span>
                  </div>
                  <div>
                    <span style="position:relative;left:-55px;">combo {{enemy.combo}}</span>
                    <span style="position:relative;left:20px;"> CE {{enemy.CE}}</span>
                  </div>
                  <div>
                    <span style="position:relative;left:-70px;">status {{enemy.status}}</span>
                  </div>
                  <el-button type="text" style="position:relative;left:-20px;" @click="fight(enemy.id)"><font size="4">Fight</font></el-button>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>
    </div>

  </div>


</template>

<script>
//import GameContainer from '@/components/fightingSystem/gamecontainer'
import WarriorBase from '@/js/warriorBase'
import LordBase from '@/js/lordBase'
import Database from '@/js/database'
import Vue from 'vue'

export default {
  name: 'fight',
  data () {
    return {
      open: false,
      docked: true,
      rolePic: '/static/warrior.png',
      curAddr: window.web3.eth.accounts[0],
      enemylist: [],
      accountDetail:{},
      chosenToken: {},
      indexMapping: [],
      NotHasChosen: true,
      titleList: ['战士','勇士','战士','百夫长','军团长','将军','统帅','初级格斗教练','中级格斗教练','高级格斗教练','大师级教练']
    }
  },
  
  beforeCreate: function(){
    let self = this
    
    self.curAddr = window.web3.eth.accounts[0]
    Database.getAccountEth(self.curAddr).then(getAccountEth => {
      var accountEthVal = window.web3.fromWei(Number(getAccountEth),'ether')
      console.log('accountEthVal : '+ accountEthVal)
      Vue.set(self.accountDetail,'accountValue',accountEthVal)
    })
    
    var choiceId = localStorage.choiceId
    if (choiceId != 'undefined') {
      WarriorBase.getToken(Number(choiceId)).then(function (value) {
          var obj = {}
          obj.id = choiceId
          obj.val = Number(value[0])
          obj.winCount = Number(value[1])
          obj.lossCount = Number(value[2])
          obj.combo = Number(value[3])
          obj.title = self.titleList[Number(value[4])]
          obj.prestige = Number(value[5])
          obj.CE = Number(value[6])
          obj.createTime = Number(value[7])
          obj.destroyTime = Number(value[8])
          obj.status = self.calcStatus(obj.title, obj.createTime, obj.destroyTime)
          self.chosenToken = obj
          self.NotHasChosen = false
      })
    }

    WarriorBase.getEnemyTokens().then(function(enemyTokens) {
      var tokens =[]
      var tokenOwners = []
      var tokenIds = []
      var enemyTokenNum = enemyTokens.length
      enemyTokens.forEach(value => {
        tokens.push(WarriorBase.getToken(Number(value)))
        tokenOwners.push(WarriorBase.getTokenOwner(Number(value)))  
        tokenIds.push(Number(value))
      })

      let promiseList = Promise.all(tokens)
      promiseList.then(function(value) {
        for (var i = 0; i< enemyTokenNum; i++) {
          var obj = {}
          obj.val = Number(value[i][0])
          obj.winCount = Number(value[i][1])
          obj.lossCount = Number(value[i][2])
          obj.combo = Number(value[i][3])
          obj.title = self.titleList[Number(value[i][4])]
          obj.prestige = Number(value[i][5])
          obj.CE = Number(value[i][6])
          obj.createTime = Number(value[i][7])
          obj.destroyTime = Number(value[i][8])
          obj.status = self.calcStatus(obj.title, obj.createTime, obj.destroyTime)
          obj.winningPercentage = Number(self.chosenToken.CE * 100 / (self.chosenToken.CE + obj.CE)).toFixed(2)
          obj.id = tokenIds[i]
          self.indexMapping.push(obj.id)
          //obj.index = i
          self.enemylist.push(obj)
        }

        let promiseListAddress = Promise.all(tokenOwners)
        promiseListAddress.then(function(addresses) {
          for(var i = 0; i < enemyTokenNum; i++) {
            var obj = self.enemylist[i]
            obj.owner = String(addresses[i])
            self.enemylist[i] = obj
          }
        })

      })
    })
  }, 

  methods: {
    toggle (flag) {
      this.open = !this.open
      this.docked = !flag
	  },
  
    calcStatus: function (title, createTime, destroyTime) {
      if (title >= 7)
        return 'coach'
      var timestamp = Date.parse(new Date())
      if (timestamp - createTime <= 1800)
        return 'beginner'
      if (timestamp - destroyTime <= 3600)
        return 'suicider'
      return 'active'
    },

    routerToWeapon(){
      this.$router.push('/weapon')
    },

    routerToMyWarrior(){
      this.$router.push('/myWarrior')
    },

    routerToActivity(){
      this.$router.push('/activity')
    },

    routerToTravel(){
      this.$router.push('/travel')
	  },
	
    routerToAdopt(){
      this.$router.push('/adopt')
    },

    routerToFight(){
      this.$router.push('/fight')
    },

    fight(defenceId) {
      let self = this
      var attackId = self.chosenToken.id
      var attackAddrPromise = WarriorBase.getTokenOwner(Number(attackId))
      var defenceAddrPromise = WarriorBase.getTokenOwner(Number(defenceId))
      
      attackAddrPromise.then(function (value){
        console.log('attackAddr = '+ value)
        var attackAddr = value
        defenceAddrPromise.then(function (value) {
          var defenceAddr = value
          console.log('defenceAddr = '+ value)

          LordBase.battle(
            Number(attackId),
            Number(defenceId),
            ).then( function(value) {
              console.log('vue value : '+ Number(value))
              if (Number(value) == 1) {
                self.$message({
                message: 'You won!',
                type: 'success'
                })
              }
              else {
                self.$message({
                message: 'You Lose!',
                type: 'error'
                })
              }

              WarriorBase.getToken(Number(defenceId)).then(function (value) {
                var obj = {}
                var indexInEnemyList = self.indexMapping.indexOf(defenceId)
                Vue.set(self.enemylist[indexInEnemyList],'val',Number(value[0]))
                Vue.set(self.enemylist[indexInEnemyList],'winCount',Number(value[1]))
                Vue.set(self.enemylist[indexInEnemyList],'lossCount',Number(value[2]))
                Vue.set(self.enemylist[indexInEnemyList],'combo',Number(value[3]))
                Vue.set(self.enemylist[indexInEnemyList],'title',self.titleList[Number(value[4])])
                Vue.set(self.enemylist[indexInEnemyList],'prestige',Number(value[5]))
                Vue.set(self.enemylist[indexInEnemyList],'CE',Number(value[6]))
                
                WarriorBase.getToken(Number(attackId)).then(function (value) {
                  var obj = {}
                  Vue.set(self.chosenToken,'val',Number(value[0]))
                  Vue.set(self.chosenToken,'winCount',Number(value[1]))
                  Vue.set(self.chosenToken,'lossCount',Number(value[2]))
                  Vue.set(self.chosenToken,'combo',Number(value[3]))
                  Vue.set(self.chosenToken,'title',self.titleList[Number(value[4])])
                  Vue.set(self.chosenToken,'prestige',Number(value[5]))
                  Vue.set(self.chosenToken,'CE',Number(value[6]))
                  var newPercentage =  self.chosenToken.CE / (self.chosenToken.CE + self.enemylist[indexInEnemyList].CE) * 100
                  Vue.set(self.enemylist[indexInEnemyList],'winningPercentage',Number(newPercentage).toFixed(2))
                })
              })

          })
        })
      })
      
    }
  }
}


</script>

<style>
#fight {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 10%;
  width:960;
  margin-left:auto;
  margin-right:auto;
}

.TopBar {
  position:absolute;
  text-align: left;
  top: 0%;
  width: 100%;
  left: 0%;
}

.curAddr {
  font-size: 70%;
  margin-left: 2.5%;
}

.Save {
    margin-left: 30%;
}

.el-icon-btn {
	margin-left: 40%;
}
</style>
