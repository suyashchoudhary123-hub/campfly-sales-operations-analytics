let
    Source = Excel.Workbook(File.Contents(pFilePath), null, true)
in
    Source