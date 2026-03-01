import 'package:flutter/material.dart';
import '../services/video_cache_manager.dart';

/// 缓存管理页面
class CacheManagerPage extends StatefulWidget {
  const CacheManagerPage({super.key});

  @override
  State<CacheManagerPage> createState() => _CacheManagerPageState();
}

class _CacheManagerPageState extends State<CacheManagerPage> {
  late Future<_CacheInfo> _cacheInfoFuture;

  @override
  void initState() {
    super.initState();
    _refreshCacheInfo();
  }

  void _refreshCacheInfo() {
    _cacheInfoFuture = _loadCacheInfo();
  }

  Future<_CacheInfo> _loadCacheInfo() async {
    final size = await VideoCacheManager.getCacheSize();
    final sizeStr = await VideoCacheManager.getFormattedCacheSize();
    final videos = await VideoCacheManager.listCachedVideos();

    return _CacheInfo(
      totalSize: size,
      sizeString: sizeStr,
      cachedVideos: videos,
    );
  }

  Future<void> _clearAllCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认清空'),
        content: const Text('确定要清空所有视频缓存吗？\n\n清空后，视频会在下次播放时重新下载。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确认', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await VideoCacheManager.clearAllCache();

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✓ 已清空所有缓存')),
      );
      _refreshCacheInfo();
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✗ 清空缓存失败')),
      );
    }
  }

  Future<void> _deleteCache(String videoName) async {
    // 查找对应的 URL（这里简化处理，实际需要保存映射）
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除 "$videoName" 的缓存吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // 这里的 videoName 就是文件名，可以直接使用
    if (!mounted) return;

    _refreshCacheInfo();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('缓存管理'),
        elevation: 0,
      ),
      body: FutureBuilder<_CacheInfo>(
        future: _cacheInfoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('加载缓存信息失败: ${snapshot.error}'),
            );
          }

          final cacheInfo = snapshot.data;
          if (cacheInfo == null) {
            return const Center(child: Text('无法加载缓存信息'));
          }

          return RefreshIndicator(
            onRefresh: (_) async => _refreshCacheInfo(),
            child: ListView(
              children: [
                // 缓存统计卡片
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '缓存统计',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '缓存大小',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    cacheInfo.sizeString,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '缓存视频数',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${cacheInfo.cachedVideos.length}',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _clearAllCache,
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('清空所有缓存'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // 缓存文件列表
                if (cacheInfo.cachedVideos.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32.0),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.folder_open,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '还没有缓存视频',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '缓存的视频',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Card(
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: cacheInfo.cachedVideos.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final videoName = cacheInfo.cachedVideos[index];
                              return ListTile(
                                leading: const Icon(Icons.video_library),
                                title: Text(videoName),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () =>
                                      _deleteCache(videoName),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// 缓存信息模型
class _CacheInfo {
  final int totalSize;
  final String sizeString;
  final List<String> cachedVideos;

  _CacheInfo({
    required this.totalSize,
    required this.sizeString,
    required this.cachedVideos,
  });
}
