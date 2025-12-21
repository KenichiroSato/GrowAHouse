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
	local price = PriceProvider.GetPrice(model)
	local rate = price/100 --デフォルト
	if 1000 <= price  and price < 5000 then
		rate = rate * 0.8
	elseif 5000 <= price  and price < 10000 then
		rate = rate * 0.6
	elseif  10000 <= price  and price < 100000 then
		rate = rate * 0.3
	elseif 100000 < price then
		rate = rate * 0.1			
	end
	
	local rateAtt = model:GetAttribute("rate")
	if rateAtt and rateAtt > 0 then
		rate = rateAtt
	end
	return rate
end

return PriceProvider
