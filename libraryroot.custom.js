// 创建一个 video 元素
const video = document.createElement('video');

// 设置 preload 属性
video.preload = 'auto';

// 设置视频源
video.src = 'skins/gbc/main.webm';

// 设置视频属性
video.autoplay = true;
video.loop = true;
video.muted = true;

// 设置视频样式
video.style.position = 'fixed';
video.style.top = '50%';
video.style.left = '50%';
video.style.transform = 'translate(-50%, -50%)';
video.style.zIndex = '-1';

// 监听视频元数据加载完成事件
video.addEventListener('loadedmetadata', function () {
    adjustVideoSize();
});

// 定义调整视频大小的函数
function adjustVideoSize() {
    const windowWidth = window.innerWidth;
    const windowHeight = window.innerHeight;
    const videoWidth = video.videoWidth;
    const videoHeight = video.videoHeight;
    const windowAspectRatio = windowWidth / windowHeight;
    const videoAspectRatio = videoWidth / videoHeight;

    if (videoAspectRatio > windowAspectRatio) {
        // 视频宽高比大于窗口宽高比，缩放至高度与窗口相等
        video.style.height = '100%';
        video.style.width = 'auto';
    } else {
        // 视频宽高比小于等于窗口宽高比，缩放至宽度与窗口相等
        video.style.width = '100%';
        video.style.height = 'auto';
    }
}

// 监听窗口大小变化事件
window.addEventListener('resize', adjustVideoSize);



// 获取 body 元素
const body = document.body;
// 获取 body 的第一个子节点
const firstChild = body.firstChild;

// 将视频元素插入到 body 的第一个子节点之前
body.insertBefore(video, firstChild);
    