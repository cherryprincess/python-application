<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" indent="yes"/>
  <xsl:param name="sourceFolder"/>

  <!-- Count categories -->
  <xsl:variable name="NumberOfItems" select="count(OWASPZAPReport/site/alerts/alertitem)"/>
  <xsl:variable name="NumberOfFailed" select="count(OWASPZAPReport/site/alerts/alertitem[riskcode &gt;= 3])"/>
  <xsl:variable name="NumberOfPassed" select="count(OWASPZAPReport/site/alerts/alertitem[riskcode &lt; 2])"/>
  <xsl:variable name="NumberOfWarnings" select="count(OWASPZAPReport/site/alerts/alertitem[riskcode = 2])"/>

  <!-- Set overall test result -->
  <xsl:variable name="TestResult">
    <xsl:choose>
      <xsl:when test="$NumberOfFailed &gt; 0">Failed</xsl:when>
      <xsl:otherwise>Passed</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="generatedDateTime" select="OWASPZAPReport/generated"/>

  <xsl:template match="/">
    <test-run id="1" name="OWASPReport" fullname="OWASPConvertReport"
              testcasecount="{$NumberOfItems}" result="{$TestResult}"
              total="{$NumberOfItems}" passed="{$NumberOfPassed}" failed="{$NumberOfFailed}"
              warnings="{$NumberOfWarnings}" inconclusive="0" skipped="0"
              asserts="{$NumberOfItems}" engine-version="3.9.0.0" clr-version="4.0.30319.42000"
              start-time="{$generatedDateTime}" end-time="{$generatedDateTime}" duration="0">
      <command-line>zap-full-scan</command-line>
      <test-suite type="Assembly" id="0-1005" name="OWASP" fullname="OWASP"
                  runstate="Runnable" testcasecount="{$NumberOfItems}" result="{$TestResult}"
                  site="Child" start-time="{$generatedDateTime}" end-time="{$generatedDateTime}"
                  duration="0.352610" total="{$NumberOfItems}" passed="{$NumberOfPassed}"
                  failed="{$NumberOfFailed}" warnings="{$NumberOfWarnings}" inconclusive="0"
                  skipped="0" asserts="{$NumberOfItems}">
        <environment framework-version="3.11.0.0" clr-version="4.0.30319.42000"
                     os-version="Microsoft Windows NT 10.0.17763.0" platform="Win32NT"
                     cwd="C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\Common7\IDE"
                     machine-name="Azure Hosted Agent" user="flacroix" user-domain="NORTHAMERICA"
                     culture="en-US" uiculture="en-US" os-architecture="x86"/>
        <test-suite type="TestFixture" id="0-1000" name="OWASPZAPTest" fullname="OWASPZAPTest"
                    classname="OWASPZAPTest" runstate="Runnable" testcasecount="{$NumberOfItems}"
                    result="{$TestResult}" site="Child" start-time="{$generatedDateTime}"
                    end-time="{$generatedDateTime}" duration="0.495486" total="{$NumberOfItems}"
                    passed="{$NumberOfPassed}" failed="{$NumberOfFailed}" warnings="{$NumberOfWarnings}"
                    inconclusive="0" skipped="0" asserts="{$NumberOfItems}">

          <!-- Loop through all alerts -->
          <xsl:for-each select="OWASPZAPReport/site/alerts/alertitem">
            <xsl:variable name="risk" select="riskcode"/>
            <xsl:variable name="status">
              <xsl:choose>
                <xsl:when test="$risk &gt;= 3">Failed</xsl:when>
                <xsl:otherwise>Passed</xsl:otherwise>
              </xsl:choose>
            </xsl:variable>

            <test-case id="{position()}" name="{name}" fullname="{name}" methodname="Stub"
                       classname="OWASPZAPTest" runstate="Runnable" result="{$status}"
                       start-time="{$generatedDateTime}" end-time="{$generatedDateTime}" duration="0" asserts="1">

              <!-- If failed -->
              <xsl:if test="$status = 'Failed'">
                <failure>
                  <message>
                    <xsl:value-of select="desc"/>. 
                    <xsl:value-of select="solution"/>
                  </message>
                  <stack-trace>
                    <xsl:for-each select="instances/instance">
                      <xsl:value-of select="uri"/>, <xsl:value-of select="method"/>, <xsl:value-of select="param"/>,
                    </xsl:for-each>
                  </stack-trace>
                </failure>
              </xsl:if>

              <!-- If warning (riskcode = 2) -->
              <xsl:if test="$risk = 2">
                <reason>
                  <message>
                    ⚠️ Warning: <xsl:value-of select="desc"/>
                  </message>
                </reason>
              </xsl:if>

            </test-case>
          </xsl:for-each>

        </test-suite>
      </test-suite>
    </test-run>
  </xsl:template>
</xsl:stylesheet>
