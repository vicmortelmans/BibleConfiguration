<?xml version="1.0"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions">
   
  <xsl:strip-space elements="*"/>
 
  <!--xsl:include href="https://github.com/vicmortelmans/BibleConfiguration/raw/master/liturgy.calendar.lib2.xslt"/-->
  <xsl:include href="liturgy.calendar.lib2.xslt"/>
    
  <xsl:param name="set"/>
  <xsl:param name="date" select="'2011-08-09'"/>
  <xsl:param name="options" select="'epiphany-alt,corpuschristi-std,ascension-std'"/>
  <xsl:param name="score" select="yes"/>
  
  <xsl:variable name="year">
    <xsl:call-template name="liturgical-year">
        <xsl:with-param name="date" select="$date"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="cycle-sundays">
    <map number="1" cycle="A"/>
    <map number="2" cycle="B"/>
    <map number="0" cycle="C"/>
  </xsl:variable>

  <xsl:variable name="cycle-weekdays">
    <map number="1" cycle="I"/>
    <map number="0" cycle="II"/>
  </xsl:variable>

  <xsl:template match="liturgicaldays">
    <xsl:variable name="results">
      <xsl:apply-templates/>
    </xsl:variable>
    <results>
      <xsl:choose>
         <xsl:when test="$score = 'yes'">
           <!-- there's no other result with higher score OR this result's coincideswith matches another result -->
           <xsl:copy-of select="$results/coordinates[not(../coordinates/@score &lt; @score) 
             or (not(@coincideswith = '') and ../coordinates[matches(.,concat('',current()/@coincideswith))])]"/>
         </xsl:when>
         <xsl:otherwise>
	   <xsl:copy-of select="$results"/>
         </xsl:otherwise>
      </xsl:choose>
      <cycle-sundays>
        <xsl:value-of select="$cycle-sundays/map[@number = $year mod 3]/@cycle"/>
      </cycle-sundays>
      <cycle-weekdays>
        <xsl:value-of select="$cycle-weekdays/map[@number = $year mod 2]/@cycle"/>
      </cycle-weekdays>
    </results>
  </xsl:template>

  <xsl:template match="coordinaterules[not($set) or @set = $set]">
    <xsl:variable name="calendardate" select="format-date(xs:date($date),'[M01]-[D01]')"/>
    <xsl:message>checking coordinaterules for <xsl:value-of select="@set"/> on <xsl:value-of select="$calendardate"/></xsl:message>
    <xsl:if test="(@start-date &lt;= $calendardate) and
                  ($calendardate &lt;= @stop-date)">
      <xsl:variable name="coordinates">
        <xsl:apply-templates/>
      </xsl:variable>
      <xsl:if test="$coordinates != ''">
        <xsl:message>got <xsl:value-of select="@set"/> coordinates within date range: <xsl:value-of select="$coordinates"/></xsl:message>
        <xsl:variable name="liturgicalday" select="//liturgicalday[coordinates = $coordinates][set = current()/@set][1]"/><!-- multiple <liturgicaldays> may have the same @coordinates -->
        <xsl:if test="$liturgicalday">
          <xsl:variable name="rank" select="$liturgicalday/rank/@nr"/>
          <xsl:variable name="precedence" select="$liturgicalday/precedence"/>
          <xsl:variable name="overlap-priority" select="//coordinaterules[@set = current()/@set]/@overlap-priority"/>
          <xsl:variable name="score" select="format-number(10000 * $rank + 100 * $precedence + $overlap-priority,'000000')"/>
          <coordinates set="{@set}" liturgicalday="{$liturgicalday/name}" rank="{$rank}" precedence="{$precedence}" overlap-priority="{$overlap-priority}" score="{$score}" coincideswith="{$liturgicalday/coincideswith}">
             <xsl:value-of select="replace($coordinates,'X','Y')"/>
          </coordinates>
        </xsl:if>
      </xsl:if>
    </xsl:if>
  </xsl:template>
    
  <xsl:template match="coordinaterules"/>
  <xsl:template match="liturgicalday"/>
  
</xsl:stylesheet>
