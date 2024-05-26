global class CASE_CaseHelper {
    
    @InvocableMethod(label='Get number of KnowledgeArticles on Case' description='Gets the number of Knowledge Articles attached to a specific Case')
    global static List<Integer> getNumberOfArticlesFromCase(List<parameters> parameterList) {

        List<Integer> returnList = new List<Integer>();

        // Get CaseIds for Query
        List<Id> caseIds = new List<Id>();
        for (parameters param : parameterList) {
            caseIds.add(param.inputCase.Id);
        }

        // Query CaseArticler per Case
        List<Case> casesWithArticleList = [SELECT Id, (SELECT Id FROM CaseArticles) FROM Case WHERE Id IN :caseIds];

        // Create map with number of CaseArticles per Case
        Map<Id, List<CaseArticle>> caseIdCaseArticleMap = new Map<Id, List<CaseArticle>>();
        for (Case c : casesWithArticleList) {
            if (c.CaseArticles != null) {
                caseIdCaseArticleMap.put(c.Id, c.CaseArticles);
            } else {
                caseIdCaseArticleMap.put(c.Id, new List<CaseArticle>());
            }
        }

        // Create returnList
        for (Id caseId : caseIds) {
            returnList.add(caseIdCaseArticleMap.get(caseId).size());
        }

        return returnList;
    }

    global class parameters {
        @InvocableVariable(required=true label='Case')
        public Case inputCase;
    }

}