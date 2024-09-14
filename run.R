library(telegram.bot)

#BOT_TOKEN is in repository variable in github
bot <- Bot(token = BOT_TOKEN)

#to handle messages
handle_message <- function(bot, update) {
  # Get the message text
  user_input <- update$message$text
  
  #R code provided by the user
  tryCatch({
    # Evaluate the code
    result <- eval(parse(text = user_input))
    
    # Check if a plot was generated
    if (length(dev.list()) > 0) {
      # If a plot is active, save it as a PNG
      image_path <- tempfile(fileext = ".png")
      png(image_path)
      
      # Re-execute the code to regenerate the plot in PNG format
      eval(parse(text = user_input))
      dev.off()
      
      # Send the image back to the user
      bot$sendPhoto(chat_id = update$message$chat_id, photo = image_path)
      
      # Optionally, also send text output if any
      result_str <- capture.output(print(result))
      if (length(result_str) > 0) {
        bot$sendMessage(chat_id = update$message$chat_id, text = paste(result_str, collapse = "\n"))
      }
    } else {
      # If no plot is generated, just send the result as text
      result_str <- capture.output(print(result))
      bot$sendMessage(chat_id = update$message$chat_id, text = paste(result_str, collapse = "\n"))
    }
  }, error = function(e) {
    # If there is an error, send the error message back to the user
    bot$sendMessage(chat_id = update$message$chat_id, text = paste("Error:", e$message))
  })
}

# Create the updater and dispatcher
updater <- Updater(token = BOT_TOKEN)

# Add the handler for messages
updater <- updater + MessageHandler(handle_message, MessageFilters$text)

# Start the bot
updater$start_polling()
