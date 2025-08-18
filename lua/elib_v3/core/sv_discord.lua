// Script made by Eve Haddox
// discord evehaddox


///////////////////
// Discord Webhooks
///////////////////
function Elib.SendWebhook(WebhookURL, Content, PureText)
    if !WebhookURL then
        MsgN("Missing webhook URL, cannot send message.")
        return
    end
    if !Content then
        MsgN("Missing message content, cannot send message.")
        return
    end

    local title = Content.title or [[ERROR! CODE 01: MISSING TITLE!]]
    local colorson = Content.color or 0xFF1493
    local desc = Content.text or [[ERROR! CODE 02: MISSING CONTENT!]]
    local imageURL = Content.image or ""
    local footerText = Content.footerText or ""
    local tabela = {}

    if !PureText then
        tabela = {
            ["embeds"] = {
                [1] = {
                    color = tostring(colorson),
                    description = desc,
                    footer = {
                        text = footerText
                    },
                    thumbnail = {
                        url = imageURL
                    },
                    title = title
                }
            }
        }
    else
        tabela = {
            ["content"] = Content.text
        }
    end

    HTTP({
        method = "POST",
        url = WebhookURL,
        headers = { ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.113 Safari/537.36" },
        type = "application/json",
        body = util.TableToJSON(tabela),
        success = function(code, body, headers)
        end,
        failure = function(reason)
            print("Webhook kurwen machen kaputen, powoden: " .. reason)
        end
    })
end