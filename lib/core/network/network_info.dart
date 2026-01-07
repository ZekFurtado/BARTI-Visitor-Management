class NetworkInfo {
  final String url;

  const NetworkInfo({required this.url});

  // const NetworkInfo.uat() : this(url: "3.110.54.43:8080");
  const NetworkInfo.uat() : this(url: "api.samtadoot.shrameco.com");

  // const NetworkInfo.uat() : this(url: "uatapi.shrameco.com");

  const NetworkInfo.prod() : this(url: "api.shrameco.com");
}
