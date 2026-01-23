import { defineConfig } from 'vitepress'
import mathjax3 from 'markdown-it-mathjax3'

export default defineConfig({
  title: 'LuaSTG 自机教程',
  description: 'LuaSTG 自机教程',
  base: '/lstg-player-tutorial/',

  themeConfig: {
    nav: [
      { text: '首页', link: '/' },
      { text: 'GitHub', link: 'https://github.com/TengoDango/lstg-player-tutorial' }
    ],

    sidebar: [
      {
        items: [
          { text: '序言', link: '/' },
          { text: '术语表', link: '/notations' }
        ]
      },
      {
        text: '从零开始的自机之旅',
        items: [
          { text: 'Hello world！第一个自机', link: '/mainline/helloworld' },
          { text: '复刻：灵梦自机', link: '/mainline/reimu' },
          { text: '附录：自机代码下载', link: '/mainline/appendix' }
        ]
      },
      {
        text: '我必须立刻开始品鉴 data',
        items: [
          { text: '如果你想要，你得自己来拿', link: '/dataer/if-you-want-it' },
          { text: '自机相关属性整理', link: '/dataer/fields' },
          { text: 'player.lua 解析', link: '/dataer/player' },
          { text: 'player_system.lua 解析', link: '/dataer/player-system' },
        ]
      },
      {
        text: '附录',
        items: [
          { text: 'lstg.GameObject.lua', link: '/appendix/lstg-gameobject' },
          { text: 'player.lua', link: '/appendix/player-lua' },
          { text: 'player_system.lua', link: '/appendix/player-system-lua' },
          { text: 'PlayerWalkImageSystem', link: '/appendix/wisys-lua' }
        ]
      }
    ],

    socialLinks: [
      { icon: 'github', link: 'https://github.com/TengoDango' }
    ],

    search: {
      provider: 'local'
    }
  },

  markdown: {
    lineNumbers: true,
    math: true,
    config: (md) => {
      md.use(mathjax3)
    }
  }
})

