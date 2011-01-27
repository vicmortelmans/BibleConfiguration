<?xml version="1.0"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema">
  <xsl:output method="xml" indent="yes"/>
  <xsl:param name="year"/>
  <xsl:include href="liturgy.calendar.lib.xslt"/>

  <xsl:template match="/">
    <xsl:message><xsl:copy-of select="/"/></xsl:message>
    <xsl:choose>
      <xsl:when test="$year">
        <xsl:variable name="easterdates" select="document(data/easterdatesfile)/easterdates"/>
        <xsl:variable name="generaldata" select="document(data/rulesetfile)"/>
        <xsl:variable name="dateruleset">
          <xsl:copy-of select="$generaldata/liturgicaldays/liturgicalday|data/liturgicaldays/liturgicalday"/>
        </xsl:variable>
        <xsl:variable name="coordinateruleset">
          <xsl:copy-of select="$generaldata/coordinaterules"/>
        </xsl:variable> 
        <xsl:variable name="env">
          <year>
            <xsl:value-of select="$year"/>
          </year>
          <xsl:copy-of select="$dateruleset"/>
          <xsl:copy-of select="$coordinateruleset"/>
          <xsl:copy-of select="$easterdates"/>
        </xsl:variable>
        <xsl:message>startDate rules : <xsl:copy-of select="$dateruleset/liturgicalday[name='All Souls']/daterules"/></xsl:message>
        <xsl:variable name="startDate">
          <xsl:apply-templates select="$dateruleset/liturgicalday[name='All Souls']/daterules">
            <xsl:with-param name="env">
              <xsl:copy-of select="$env"/>
            </xsl:with-param>
          </xsl:apply-templates>
        </xsl:variable>
        <xsl:message>startDate : <xsl:value-of select="$startDate"/></xsl:message>
        <xsl:variable name="endDate">
          <xsl:apply-templates select="$dateruleset/liturgicalday[name='Saturday in the Thirty-fourth Week of Ordinary Time']/daterules">
            <xsl:with-param name="env">
              <xsl:copy-of select="$env"/>
            </xsl:with-param>
          </xsl:apply-templates>
        </xsl:variable>
        <xsl:message>endDate : <xsl:value-of select="$endDate"/></xsl:message>
        <xsl:variable name="dates">
          <xsl:call-template name="nextDate">
            <xsl:with-param name="previousDate" select="$startDate"/>
            <xsl:with-param name="endDate" select="$endDate"/> 
          </xsl:call-template>
        </xsl:variable>
        <table>
          <xsl:for-each select="$dates/item">
            <tr>
              <td>
                <xsl:value-of select="@date"/>
              </td>
              <td>
                <xsl:call-template name="print-for-date-all-sets">
                  <xsl:with-param name="env">
                    <xsl:copy-of select="$env"/>
                  </xsl:with-param>
                </xsl:call-template>
              </td>
            </tr>
          </xsl:for-each>
        </table>
      </xsl:when>
      <xsl:otherwise>
        <error>No year specified</error>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="nextDate">
    <xsl:param name="previousDate"/>
    <xsl:param name="endDate"/>
    <item date="{$previousDate}"/>
    <xsl:variable name="nextDate" 
      select="format-date(xs:date($previousDate) + xs:dayTimeDuration('P1D'), '[Y0001]-[M01]-[D01]')"/>
    <xsl:if test="not($nextDate &gt; $endDate)">
      <xsl:call-template  name="nextDate">
        <xsl:with-param name="previousDate" select="$nextDate"/>
        <xsl:with-param name="endDate" select="$endDate"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  
</xsl:stylesheet>
