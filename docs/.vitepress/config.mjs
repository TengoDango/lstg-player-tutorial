import { defineConfig } from 'vitepress'
import mathjax3 from 'markdown-it-mathjax3'
import { withMermaid } from 'vitepress-plugin-mermaid'

export default withMermaid({
  title: 'LuaSTG 自机教程',
  description: 'LuaSTG 自机教程',
  base: '/lstg-player-tutorial/',

  themeConfig: {
    nav: [
      { text: '首页', link: '/' },
      { text: 'GitHub', link: 'https://github.com/TengoDango/lstg-player-tutorial' }
    ],

    outline: {
      label: '页面导航',
    },
    returnToTopLabel: '返回顶部',

    docFooter: {
      prev: '上一篇',
      next: '下一篇',
    },

    darkModeSwitchLabel: '深/浅色主题',
    darkModeSwitchTitle: '切换至深色主题',

    sidebar: [
      {
        items: [
          { text: '序言', link: '/' },
          { text: '术语表', link: '/notations' }
        ]
      },
      {
        text: '主线',
        items: [
          { text: 'Hello world！第一个自机', link: '/mainline/helloworld' },
          { text: '复刻：灵梦自机', link: '/mainline/reimu' },
          { text: '附录：自机代码下载', link: '/mainline/appendix' }
        ]
      },
      {
        text: '番外',
        items: [
          { text: '环绕子机', link: '/extra/orbiting-supports' },
          { text: '自动雷', link: '/extra/auto-bomb' },
          { text: '蓄力射击', link: '/extra/charge-bullet' }
        ]
      },
      {
        text: 'Data',
        items: [
          { text: '如果你想要，你得自己来拿', link: '/dataer/if-you-want-it' },
          { text: '自机相关属性整理', link: '/dataer/fields' },
          { text: 'player.lua 解析', link: '/dataer/player' },
          { text: 'player_system.lua 解析', link: '/dataer/player-system' },
        ]
      },
    ],

    socialLinks: [
      { icon: 'github', link: 'https://github.com/TengoDango' }
    ],

    search: {
      provider: 'local',
      options: {
        translations: {
          button: { buttonText: '在文档内搜索' },
          modal: {
            resetButtonTitle: '清除搜索条件',
            noResultsText: '没有搜索结果',
            footer: {
              selectText: '确认',
              navigateText: '切换',
              closeText: '关闭'
            },
            displayDetails: '显示具体内容'
          }
        }
      }
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
