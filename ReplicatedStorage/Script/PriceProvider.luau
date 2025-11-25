local PriceProvider = {}

function PriceProvider.GetPrice(model: Model): number
	local price = 100 --デフォルト
	local priceAtt = model:GetAttribute("price")
	if priceAtt and priceAtt > 0 then
		price = priceAtt
	end
	return price
end

function PriceProvider.GetMoneyRate(model: Model): number
	local rate = PriceProvider.GetPrice(model)/100 --デフォルト
	local rateAtt = model:GetAttribute("rate")
	if rateAtt and rateAtt > 0 then
		rate = rateAtt
	end
	return rate
end

return PriceProvider
