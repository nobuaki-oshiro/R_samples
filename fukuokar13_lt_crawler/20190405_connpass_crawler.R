
library(dplyr)
library(rvest)
library(stringr)

# 初期化
res_df <- data.frame(row.names = c('title', 'address'))

# URLページング用のループ
for ( n in 1:20 ) {
  
  url <- paste0('https://connpass.com/upcoming_events/?page=', n)
  doc <- read_html(url)
  
  # 一覧内のスクレイピング用ループ
  for ( k in 1:20 ){
    #titleをとる(1 to 20)
    doc %>% html_nodes(xpath = paste0( '//*[@id="main"]/div[1]/div[', k, ']/div[2]/div/p[2]/a') ) %>% 
      html_text() -> title
    #住所をとる & 改行とスペース除去
    doc %>% html_nodes( xpath = paste0('//*[@id="main"]/div[1]/div[', k, ']/div[2]/div/p[4]/span') ) %>%
      html_text() %>%
      str_replace_all(pattern = "[\n ]+", replacement = '') -> address
    
    tmp_df <- data.frame(title, address)
    res_df <- rbind(res_df, tmp_df)
    
    print(tmp_df)
    Sys.sleep(1) #一休み
  }
}

# 一度ファイル出力
write.csv(res_df, file = 'output_100.csv')


# csvアドレスマッチングサービス
# http://newspat.csis.u-tokyo.ac.jp/geocode-cgi/geocode.cgi?action=start

data2 <- read.csv('output_100_add.csv', fileEncoding = "ISO-2022-JP", quote="")

# 可視化
library(leaflet)
leaflet(data2) %>% addTiles() %>% 
  addMarkers(~fX, ~fY, label=~title,
             clusterOptions = markerClusterOptions())