public with sharing class UTIL_RowIterator {

    public static List<String> getList(String textData, String lineSeperator) {
        System.debug('START -- UTIL_RowIterator - getList');
        List<String> rows = new List<String>();

        try {

            System.debug('==> Number of Lineseperators found: ' + textData.countMatches(lineSeperator));
            Integer startpos = 0;
            for (Integer i = 0; i < textData.countMatches(lineSeperator); i++) {
                Integer endPos = textData.indexOf(lineSeperator, startpos);
                rows.add(textData.subString(startPos, endPos));
                startPos = endPos+1;
            }

        } catch (Exception e) {
            HandleCustomException.LogException(e);
        }
        System.debug('END -- UTIL_RowIterator - getList');
        return rows;
    }
}