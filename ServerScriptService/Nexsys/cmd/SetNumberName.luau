return function(folder : Folder)
	for i, part in ipairs(folder:GetChildren()) do
		if part:IsA("Model") then
			part.Name = i
		end
	end
end