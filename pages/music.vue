<template>
  <div :style="{ height: height + 'px' }" class="page">
    <div class="player">
      <button :disabled="!playerState.ready" class="prev-song" @click="prevSong">
        <i class="iconfont icon-music-prev"/>
      </button>
      <div class="album-box">
        <div class="circle-progress">
          <svg viewBox="0 0 100 100">
            <path
              :d="trackPath"
              :stroke-width="relativeStrokeWidth"
              class="circle-progress-circle-track"
              stroke="rgba(197, 197, 197, 0.4)"
              fill="none"
            />
            <path
              :d="trackPath"
              :stroke-width="relativeStrokeWidth"
              :style="circlePathStyle"
              class="circle-progress-circle-path"
              stroke="rgba(190, 190, 190, 0.7)"
              stroke-linecap="bevel"
              fill="none"
            />
          </svg>
        </div>
        <div :class="{ 'playing': playerState.playing }" class="song-bg-box">
          <img :src="currentSongPicUrl">
        </div>
        <div class="toggle-box">
          <transition name="module" mode="out-in">
            <button
              v-if="playerState.playing"
              key="pause"
              :disabled="!playerState.ready"
              class="toggle-btn"
              @click="togglePlay"
            >
              <i class="iconfont icon-music-pause"/>
            </button>
            <button
              v-else
              key="play"
              :disabled="!playerState.ready"
              class="toggle-btn"
              @click="togglePlay"
            >
              <i class="iconfont icon-music-play"/>
            </button>
          </transition>
        </div>
        <div class="toggle-muted">
          <button :disabled="!playerState.ready" class="muted-btn" @click="toggleMuted">
            <i :class="playerState.muted ? 'icon-music-muted' : 'icon-music-volume'" class="iconfont"/>
          </button>
        </div>
      </div>
      <button :disabled="!playerState.ready" class="next-song" @click="nextSong">
        <i class="iconfont icon-music-next"/>
      </button>
    </div>
    <div class="song-info">
      <h3 class="name">
        <span v-if="currentSong">
          <span>{{ currentSong.name }}</span>
          <span>By</span>
          <span v-for="(artist, index) in currentSong.artists" :key="index">{{ artist.name }}</span>
          <span>/</span>
          <span>{{ currentSong.album.name || 'unknow' }}</span>
        </span>
        <span v-else>Kind words are the music of the world.</span>
      </h3>
      <p class="lrc">
        <span v-if="currentSongLrc.fetching">歌词加载中...</span>
        <span v-else>
          <span v-if="!currentSongLrcContent">暂无歌词</span>
          <span v-else>
            <span v-if="currentSongLrcContent.version < 3">非滚动歌词，所以我就不显示了</span>
            <span v-else>
              <transition name="module" mode="out-in">
                <span :key="currentSongRealTimeLrc" class="lrc-text" v-text="currentSongRealTimeLrc"/>
              </transition>
            </span>
          </span>
        </span>
      </p>
    </div>
  </div>
</template>

<script>
import music from '~/expansions/music'
import { isBrowser } from '~/environment/esm'
export default {
  name: 'Music',
  head() {
    return {
      title: `${this.isEnLang ? '' : this.$i18n.nav.music + ' | '}Music`
    }
  },
  data() {
    return {
      height: 0
    }
  },
  computed: {
    isEnLang() {
      return this.$store.getters['global/isEnLang']
    },
    playerState() {
      return music.state
    },
    currentSong() {
      return music.currentSong
    },
    currentSongLrc() {
      return music.lrc
    },
    currentSongPicUrl() {
      return music.currentSongPicUrl
    },
    currentSongLrcContent() {
      return music.currentSongLrcContent
    },
    currentSongRealTimeLrc() {
      return music.currentSongRealTimeLrc
    },
    relativeStrokeWidth() {
      return (15 / 450 * 100).toFixed(1)
    },
    trackPath() {
      const radius = parseInt(50 - parseFloat(this.relativeStrokeWidth) / 2, 10)
      return `M 50 50 m 0 -${radius} a ${radius} ${radius} 0 1 1 0 ${radius * 2} a ${radius} ${radius} 0 1 1 0 -${radius * 2}`
    },
    perimeter() {
      const radius = 50 - parseFloat(this.relativeStrokeWidth) / 2
      const result = 2 * Math.PI * radius
      return result
    },
    circlePathStyle() {
      const perimeter = this.perimeter
      return {
        strokeDasharray: `${perimeter}px,${perimeter}px`,
        strokeDashoffset: (1 - (this.playerState.progress) / 100) * perimeter + 'px',
        transition: 'stroke-dashoffset 0.6s ease 0s, stroke 0.6s ease'
      }
    }
  },
  created() {
    if (this.$store.state.global.isMobile) {
      this.$router.back()
    }
  },
  activated() {
    if (isBrowser) {
      this.updateScreenHeight()
      window.addEventListener('resize', this.updateScreenHeight)
    }
  },
  deactivated() {
    window.removeEventListener('resize', this.updateScreenHeight)
  },
  methods: {
    updateScreenHeight(event) {
      const screenHeight = window.innerHeight
      const minHeight = 14 * 53
      if (screenHeight - 14 * 4 > minHeight) {
        this.height = screenHeight - (14 * 12)
      } else {
        this.height = minHeight
      }
    },
    togglePlay() {
      music.humanizeOperation(music.player.togglePlay)
    },
    toggleMuted() {
      music.humanizeOperation(music.player.toggleMuted)
    },
    prevSong() {
      music.humanizeOperation(music.player.prevSong)
    },
    nextSong() {
      music.humanizeOperation(music.player.nextSong)
    }
  }
}
</script>
<style lang="scss" scoped>
.page {
  display: flex;
  justify-content: center;
  flex-direction: column;
  align-items: center;

  > .player {
    display: flex;
    justify-content: space-around;
    align-items: center;
    margin-bottom: 2em;
    width: 100%;

    > .prev-song,
    > .next-song {
      width: 3rem;

      &:hover {
        > .iconfont {
          color: $text;
        }
      }

      > .iconfont {
        font-size: 3em;
        color: $dividers;
      }
    }

    > .album-box {
      position: relative;
      display: flex;
      justify-content: center;
      align-items: center;
      width: 38rem;
      height: 38rem;
      opacity: 0.9;

      &:hover {
        opacity: 1;
      }

      @keyframes rotation {
        from {
          transform: rotate(0deg);
        }
        to {
          transform: rotate(360deg);
        }
      }

      > .song-bg-box {
        position: absolute;
        width: 100%;
        height: 100%;
        padding: 1rem;
        overflow: hidden;
        border-radius: 100%;
        animation: rotation 26s linear infinite;
        animation-play-state: paused;

        &.playing {
          animation-play-state: running;
        }

        > img {
          width: 100%;
          height: 100%;
          border-radius: 100%;
          background-color: darkgray;
          background-image: url('/images/music-bg.jpg');
          background-size: cover;
        }
      }

      > .toggle-box {
        z-index: 9;

        > .toggle-btn {
          width: 6rem;
          height: 6rem;
          line-height: 6rem;
          text-align: center;
          background-color: $module-bg;
          border-radius: 100%;
          opacity: 0.5;

          &:hover {
            opacity: 0.8;
            transform: scale(1.2);
          }

          > .iconfont {
            color: $text-reversal;
            font-size: 3em;
          }
        }
      }

      > .toggle-muted {
        position: absolute;
        bottom: 15%;

        > .muted-btn {
          > .iconfont {
            font-size: 2em;
            color: $module-hover-bg;
          }

          &:hover {
            > .iconfont {
              color: $module-bg;
            }
          }
        }
      }

      > .circle-progress {
        width: 100%;
        height: 100%;
        display: block;
        position: absolute;
      }
    }
  }

  > .song-info {
    text-align: center;

    > .name {
      margin-bottom: 1em;
    }

    > .lrc {
      @keyframes lrc-text {
        0% {
          color: $primary;
        }
        33% {
          color: $red;
        }
        66% {
          color: $accent;
        }
      }

      .lrc-text {
        color: $primary;
        // animation: lrc-text 5s linear infinite;
      }
    }
  }
}
</style>
