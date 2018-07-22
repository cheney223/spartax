<template>

  <div id="myWarrior">
    <div class="TopBar">
      <mu-appbar>
          <mu-icon-button icon="menu" slot="left" @click = "toggle()"/>
          <span>我的角斗士</span>
          <span class="curAddr">Account {{ curAddr }}</span>
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

    <div style="position: relative;top: 100px; ">
      <el-row >
        <el-col :span="4" v-for="ownToken in ownTokenList" :key="ownToken.id" :offset="3" style="margin-bottom:40px">
          <el-card v-show="ownToken.show" :body-style="{ padding: '0px', height:'360px'}" shadow="hover" style="width: 260px;height: 350px;">
            <div style="padding: 6px;height: 310px;">
              <div>
                  <!-- <div><font size="5">{{ownToken.pcname}}</font></div>
                  <div style="position: relative;top: 15px;text-align: center;">{{ownToken.pname}}</div> -->
              </div>
              <div style="position: relative;top: 30px;left:0">
                  <img src="/static/warrior.png" class="image">
                  <!-- <div style="position: relative;top: 10px;left: 66px;"><i class="el-icon-time"></i>{{ownToken.pdatesave}}</div> -->
              </div>
              <div style="position: relative;top: 0px;">
                  <!-- <i class="el-icon-view" style="position:relative;left:-80px;"></i> -->
                  <div>
                    <span style="position:relative;left:-90px;">ID {{ownToken.id}}</span>
                    <!-- <span style="position:relative; left:20px;">Value {{ownToken.val}}</span> -->
                  </div>
                  <div>
                    <span style="position:relative;left:-60px;">win {{ownToken.winCount}}</span>
                    <span style="position:relative;left: 20px;">title Lv{{ownToken.title}}</span>
                  </div>
                  <div>
                    <span style="position:relative;left:-55px;">loss {{ownToken.lossCount}}</span>
                    <span style="position:relative;left:20px;">prestige {{ownToken.prestige}}</span>
                  </div>
                  <div>
                    <span style="position:relative;left:-55px;">combo {{ownToken.combo}}</span>
                    <span style="position:relative;left:20px;"> CE {{ownToken.CE}}</span>
                  </div>
                  <el-button type="text" style="position:relative;left:-20px;" @click="pick(ownToken.id)"><font size="4">Pick</font></el-button>
                  <el-button type="text" style="position:relative;left:20px;" @click="kill(ownToken.id)"><font size="4">Kill</font></el-button>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>
    </div>

  </div>
</template>

<script>
import WarriorBase from '@/js/warriorBase'
import LordBase from '@/js/lordBase'
import Database from '@/js/database'
import Vue from 'vue'


export default {
  
  name: 'myWarrior',
  data () {
    return {
      open: false,
      docked: true,
      rolePic: "/static/warrior.png",
      curAddr: window.web3.eth.accounts[0],
      accountDetail: {},
      ownTokenList: [],
      titleList: ['','勇士','战士','百夫长','军团长','将军','统帅','初级格斗教练','中级格斗教练','高级格斗教练','大师级教练']
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

    WarriorBase.getOwnTokens().then(function(ownTokens) {
    var tokens =[]
    var tokenIds = []
    var ownTokenNum = ownTokens.length
    ownTokens.forEach(value => {
      tokens.push(WarriorBase.getToken(Number(value)))
      tokenIds.push(Number(value))
    })
    console.log('ownTokenNum : ' + ownTokenNum)
    let promiseList = Promise.all(tokens)
    promiseList.then(function(value) {
      for (var i = 0; i< ownTokenNum; i++) {
        var obj = {}
        obj.val = Number(value[i][0])
        obj.winCount = Number(value[i][1])
        obj.lossCount = Number(value[i][2])
        obj.combo = Number(value[i][3])
        obj.title = Number(value[i][4])
        obj.prestige = Number(value[i][5])
        obj.CE = Number(value[i][6])
        obj.createTime = Number(value[i][7])
        obj.destroyTime = Number(value[i][8])
        obj.id = tokenIds[i]
        obj.show = true
        self.ownTokenList.push(obj)
      }
    })
  })
 
  },

  methods: {
    toggle (flag) {
      this.open = !this.open
      this.docked = !flag
    },

    pick(choiceId) {
      let self = this
      localStorage.choiceId = choiceId
      self.$message({
          message: 'Choose  Gladiator #' + String(choiceId) + ' successfully!',
          type: 'success'
        })
    },

    kill(choiceId) {
      let self = this
      WarriorBase.killWarrior(choiceId).then(killWarrior => {
        self.$message({
          message: 'Gladiator #' + String(choiceId) + ' has been successfully killed!',
          type: 'success'
        })
        
        for (var i = 0;i<self.ownTokenList.length; i++) {
          if (self.ownTokenList[i].id == choiceId) {
            Vue.set(self.ownTokenList[i], 'show', false)
            break
          }
        }
      
      })
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
  
  }

}
</script>

<style scoped>
#myWarrior {
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

.TopBar{
    text-align: left;

}
</style>