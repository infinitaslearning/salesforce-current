public with sharing class UTIL_RowIterator {

    public static List<String> getList(String textData, String lineSeperator)
    {
        List<String> rows = new List<String>();

        try {

            Integer startpos = 0;
            for (Integer i = 0; i < textData.countMatches(lineSeperator); i++) {
                Integer endPos = textData.indexOf(lineSeperator, startpos);
                rows.add(textData.subString(startPos, endPos));
                startPos = endPos+1;
            }

        } catch (Exception e) {
            HandleCustomException.LogException(e);
        }
        
        return rows;
    }
}