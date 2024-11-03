abstract class ProviderData<T> {
  String get worksheetTitle;
  String get cacheTitle;
  void cacheClear();
  void cacheAdd(T item);
  void commit();
  Future<void> saveCache();
  void populateItemsFromCache();
}
