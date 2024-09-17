library(telegram.bot)

#Try to set in your repo secret variable for privacy
bot_token <- "YOUR_BOT_TOKEN"

bot <- Bot(token = bot_token)

install_if_needed <- function(package_name) {
  if (!require(package_name, character.only = TRUE)) {
    install.packages(package_name, repos = "http://cran.us.r-project.org")
    library(package_name, character.only = TRUE)
  }
}

handle_message <- function(bot, update) {
  user_input <- update$message$text
  
  if (grepl("^/install", user_input)) {
    package_name <- sub("^/install ", "", user_input)
    
    tryCatch({
      install_if_needed(package_name)
      bot$sendMessage(chat_id = update$message$chat_id, text = paste("Package", package_name, "installed successfully!"))
    }, error = function(e) {
      bot$sendMessage(chat_id = update$message$chat_id, text = paste("Error installing package:", e$message))
    })
  } else {
    tryCatch({
      result <- eval(parse(text = user_input))
      
      if (length(dev.list()) > 0) {
        image_path <- tempfile(fileext = ".png")
        png(image_path)
        eval(parse(text = user_input))
        dev.off()
        bot$sendPhoto(chat_id = update$message$chat_id, photo = image_path)
        
        result_str <- capture.output(print(result))
        if (length(result_str) > 0) {
          bot$sendMessage(chat_id = update$message$chat_id, text = paste(result_str, collapse = "\n"))
        }
      } else {
        result_str <- capture.output(print(result))
        bot$sendMessage(chat_id = update$message$chat_id, text = paste(result_str, collapse = "\n"))
      }
    }, error = function(e) {
      bot$sendMessage(chat_id = update$message$chat_id, text = paste("Error:", e$message))
    })
  }
}

updater <- Updater(token = bot_token)

updater <- updater + MessageHandler(handle_message, MessageFilters$text)

updater$start_polling()
