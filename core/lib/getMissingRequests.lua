local function getMissingRequests(chest)
    local missing = {}
    for i = 1, chest.request_slot_count do
        local request = chest.get_request_slot(i)
        if request then
            local current_amount = chest.get_item_count(request.name)
            if current_amount < request.count then
                local missing_amount = request.count - current_amount
                table.insert(missing, {name = request.name, count = missing_amount})
            end
        end
    end
    return missing
end

return getMissingRequests