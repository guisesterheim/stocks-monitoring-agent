use anyhow::Result;

use crate::model::stock_data::StockData;

/// Scrapes stock data from cnbc.com
/// Returns a list of stocks with their current prices and changes
pub async fn fetch_stock_data_from_cnbc(
    http_client: &reqwest::Client,
    cnbc_url: &str,
) -> Result<Vec<StockData>> {
    let _response_body = http_client
        .get(cnbc_url)
        .send()
        .await?
        .text()
        .await?;

    // TODO: implement HTML parsing with the scraper crate
    todo!("Implement cnbc.com HTML parsing")
}
