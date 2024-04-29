extends Node
class_name FileWriter

const fileName = "LevelResults"
const folderName = "Results//"
const fileExtension = ".txt"

func writeFile(content, resultNumber):
	var filePath = folderName + fileName + str(resultNumber) + fileExtension
	var file = FileAccess.open(filePath,FileAccess.WRITE)
	file.store_string(content)
	file = null
