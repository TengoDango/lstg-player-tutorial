import { defineConfig } from 'vitepress'
import mathjax3 from 'markdown-it-mathjax3'

export default defineConfig({
  title: 'LuaSTG 自机教程',
  description: 'LuaSTG 自机教程',
  base: '/lstg-player-tutorial/',
  ignoreDeadLinks: true,

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
          { text: '旅行前的准备', link: '/mainline/beginning' }
        ]
      },
      {
        text: '我必须立刻开始品鉴 data',
        items: [
          { text: '如果你想要，你得自己来拿', link: '/dataer/if-you-want-it' },
          { text: 'player.lua 解析', link: '/dataer/player' },
          { text: 'player_system.lua 解析', link: '/dataer/player-system' },
          { text: '自机行走图系统解析', link: '/dataer/wisys' },
          { text: '其他解析', link: '/dataer/others' }
        ]
      },
      {
        text: '0 人在意的附录',
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

