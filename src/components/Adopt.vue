<template>

  <div id="adopt">
    <div class="TopBar">
        <mu-appbar>
            <mu-icon-button icon="menu" slot="left" @click = "toggle()"/>
            <span>选择角斗士</span>
            <span class="curAddr">Account {{ curAddr }}</span>
            <span class="warriorNum">当前勇士数 {{ contractDetails.warriorNum }}</span>

        <el-button type="success" class="el-icon-btn" @click="getBalance()">合约资金<i class="el-icon-upload el-icon--right"></i>
          {{ contractDetails.contractBalance }} Ether
        </el-button>
            <!-- <mu-button color="indigo" class="Save" >
              <mu-icon size="36" value="backup"></mu-icon>
            </mu-button>                         -->
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

    <el-carousel :interval="4000" type="card" height="200px">
      <el-carousel-item>
        <el-card :body-style="{ padding: '0px'}">
          <!-- <img src="~examples/assets/images/hamburger.png" class="image"> -->
          <div style="padding: 14px;">
            <div>
              <span>Sword Armed Gladiator</span>
            </div>
            <div>
            <span>Value 0.01 Ether</span>
            </div>
            <div class="bottom clearfix">
              <el-button type="text" class="button1" @click="adoptLvOne()">Adopt</el-button>
            </div>
          </div>
        </el-card>
      </el-carousel-item>

      <el-carousel-item>
        <el-card :body-style="{ padding: '0px' }">
          <!-- <img src="~examples/assets/images/hamburger.png" class="image"> -->
          <div style="padding: 14px;">
            <div>
              <span>Body armor Armed Gladiator</span>
            </div>
            <div>
            <span>Value 0.05 Ether</span>
            </div>
            <div class="bottom clearfix">
              <el-button type="text" class="button2" @click="adoptLvTwo()">Adopt</el-button>
            </div>
          </div>
        </el-card>
      </el-carousel-item>


      <el-carousel-item>
        <el-card :body-style="{ padding: '0px' }">
          <!-- <img src="~examples/assets/images/hamburger.png" class="image"> -->
          <div style="padding: 14px;">
            <div>
              <span>Long Sword Armed Gladiator</span>
            </div>
            <div>
            <span>Value 0.1 Ether</span>
            </div>
            <div class="bottom clearfix">
              <el-button type="text" class="button3" @click="adoptLvThree()">Adopt</el-button>
            </div>
          </div>
        </el-card>
      </el-carousel-item>

      <el-carousel-item>
        <el-card :body-style="{ padding: '0px' }">
          <!-- <img src="~examples/assets/images/hamburger.png" class="image"> -->
          <div style="padding: 14px;">
            <div>
              <span>Trident Armed Gladiator</span>
            </div>
            <div>
            <span>Value 0.5 Ether</span>
            </div>
            <div class="bottom clearfix">
              <el-button type="text" class="button4" @click="adoptLvFour()">Adopt</el-button>
            </div>
          </div>
        </el-card>
      </el-carousel-item>

    </el-carousel>
  </div>
</template>

<script>
import WarriorBase from '@/js/warriorBase'
import LordBase from '@/js/lordBase'
import Database from '@/js/database'
import Vue from 'vue'

export default {
  name: 'adopt',
  data () {
    return {
      open: false,
      docked: true,
      rolePic: '/static/warrior.png',
      curAddr: window.web3.eth.accounts[0],
      contractDetails: {},
      accountDetail: {},
    }
  },
  // components: {
  //   GameContainer
  // },

  beforeCreate: function(){
    let self = this
    WarriorBase.getActiveWarriorListLength().then(ActiveWarriorListLength => {
      Vue.set(self.contractDetails,'warriorNum',Number(ActiveWarriorListLength))
      console.log('All token number : ' + ActiveWarriorListLength)
    })

    Database.getAccountEth(self.curAddr).then(getAccountEth => {
      var accountEthVal = window.web3.fromWei(Number(getAccountEth),'ether')
      console.log('accountEthVal : '+ accountEthVal)
      Vue.set(self.accountDetail,'accountValue',accountEthVal)
    })
  }, 

  methods: {
    toggle (flag) {
      this.open = !this.open
      this.docked = !flag
    },

    getBalance() {
      WarriorBase.getBalance().then( balance => {
        Vue.set(this.contractDetails,'contractBalance',Number(balance))
      })
    },
    
    adoptLvOne() {
      let self = this
      WarriorBase.adoptLvOne().then( ()=> {
          self.$message({
          message: 'Adpoted!',
          type: 'success'
        })
        Vue.set(self.contractDetails,'warriorNum',self.contractDetails.warriorNum + 1)
      })
    },

    adoptLvTwo() {
      let self = this
      WarriorBase.adoptLvTwo().then( ()=> {
          self.$message({
          message: 'Adpoted!',
          type: 'success'
        })
        Vue.set(self.contractDetails,'warriorNum',self.contractDetails.warriorNum + 1)
      })
    },

    adoptLvThree() {
      let self = this
      WarriorBase.adoptLvThree().then( ()=> {
          self.$message({
          message: 'Adpoted!',
          type: 'success'
        })
        Vue.set(self.contractDetails,'warriorNum',self.contractDetails.warriorNum + 1)
      })
    },

    adoptLvFour() {
      let self = this
      WarriorBase.adoptLvFour().then( ()=> {
          self.$message({
          message: 'Adpoted!',
          type: 'success'
        })
        Vue.set(self.contractDetails,'warriorNum',self.contractDetails.warriorNum + 1)
      })
    },


    routerToMyWarrior(){
      this.$router.push('/myWarrior')
    },

    routerToAdopt(){
      this.$router.push('/adopt')
    },

    routerToFight(){
      this.$router.push('/fight')
    }
  }
}


</script>

<style>
#adopt {
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

.bottom {
  margin-top: 13px;
  line-height: 12px;
}

.button1 {
  padding: 0;
  float: center;
}

.button2 {
  padding: 0;
  float: center;
}

.button3 {
  padding: 0;
  float: center;
}

.button4 {
  padding: 0;
  float: center;
}
</style>
