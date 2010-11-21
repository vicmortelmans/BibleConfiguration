<?xml version="1.0"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema">
  <xsl:output method="xml" indent="yes"/>
  <xsl:param name="year"/>
  <xsl:param name="particulardatafile"/><!-- required ! -->
  <xsl:variable name="particulardata" select="document($particulardatafile)/data"/>
  <xsl:variable name="easterdates" select="document($particulardata/easterdatesfile)/easterdates"/>
  <xsl:template match="liturgicaldays">
    <xsl:choose>
      <xsl:when test="$year">
        <xsl:copy>
          <xsl:for-each-group select="liturgicalday|$particulardata/liturgicaldays/liturgicalday" group-by="precedence">
            <xsl:sort select="precedence"/>
            <xsl:for-each select="current-group()">
              <xsl:variable name="dates">
                <xsl:choose>
                  <xsl:when test="optionaldaterules[matches($particulardata/options,@option)]">
                    <xsl:apply-templates select="optionaldaterules/*"/>                  
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:apply-templates select="daterules/*"/>                  
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
              <xsl:variable name="liturgicalday" select="."/>
              <xsl:for-each select="$dates">
                <liturgicalday>
                  <xsl:copy-of select="$liturgicalday/*[not(matches(local-name(),'daterules'))]"/>
                  <xsl:copy-of select="."/>
                </liturgicalday>
              </xsl:for-each>
            </xsl:for-each>
          </xsl:for-each-group>
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <error>No year specified</error>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  
  <xsl:template match="date">
    <xsl:choose>
      <xsl:when test="@*">
        <xsl:variable name="dateInStartYear">
          <xsl:number value="number($year) - 1" format="0001"/>
          <xsl:text>-</xsl:text>
          <xsl:number value="@month" format="01"/>
          <xsl:text>-</xsl:text>
          <xsl:number value="@day" format="01"/>
        </xsl:variable>
        <xsl:variable name="dateInEndYear">
          <xsl:number value="number($year)" format="0001"/>
          <xsl:text>-</xsl:text>
          <xsl:number value="@month" format="01"/>
          <xsl:text>-</xsl:text>
          <xsl:number value="@day" format="01"/>
        </xsl:variable>
        <xsl:variable name="dateIn2000">
          <xsl:number value="2000" format="0001"/>
          <xsl:text>-</xsl:text>
          <xsl:number value="@month" format="01"/>
          <xsl:text>-</xsl:text>
          <xsl:number value="@day" format="01"/>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="xs:date($dateIn2000) &gt; xs:date('2000-12-03')">
            <!--return the date for $year-1-->
            <date>
              <xsl:value-of select="$dateInStartYear"/>
            </date>
          </xsl:when>
          <xsl:when test="xs:date($dateIn2000) &lt; xs:date('2000-11-27')">
            <!--return the date for $year-->
            <date>
              <xsl:value-of select="$dateInEndYear"/>
            </date>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="startDayRules">
              <weeks-before nr="3">
                <weekday-before day="Sunday">
                  <date>
                    <xsl:number value="number($year) - 1" format="0001"/>
                    <xsl:text>-</xsl:text>
                    <xsl:number value="12"/>
                    <xsl:text>-</xsl:text>
                    <xsl:number value="25"/>
                  </date>
                </weekday-before>
              </weeks-before>
            </xsl:variable>
            <xsl:variable name="startDay">
              <xsl:apply-templates select="$startDayRules"/>
            </xsl:variable>
            <xsl:variable name="endDayRules">
              <weeks-before nr="3">
                <weekday-before day="Sunday">
                  <date>
                    <xsl:number value="number($year)" format="0001"/>
                    <xsl:text>-</xsl:text>
                    <xsl:number value="12"/>
                    <xsl:text>-</xsl:text>
                    <xsl:number value="25"/>
                  </date>
                </weekday-before>
              </weeks-before>
            </xsl:variable>
            <xsl:variable name="endDay">
              <xsl:apply-templates select="$endDayRules"/>
            </xsl:variable>
            <xsl:if test="xs:date($dateInStartYear) &gt; xs:date($startDay)">
              <date>
                <xsl:value-of select="$dateInStartYear"/>
              </date>
            </xsl:if>
            <xsl:if test="xs:date($dateInEndYear) &lt; xs:date($endDay)">
              <date>
                <xsl:value-of select="$dateInEndYear"/>
              </date>
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="easterdate">
    <!-- using $year is OK, easter never falls before 1/1 -->
    <date>
      <xsl:number value="number($year)" format="0001"/>
      <xsl:text>-</xsl:text>
      <xsl:number value="$easterdates/easterdate[year=$year]/month" format="01"/>
      <xsl:text>-</xsl:text>
      <xsl:number value="$easterdates/easterdate[year=$year]/day" format="01"/>
    </date>
  </xsl:template>
  
  <xsl:template match="relative-to">
    <xsl:apply-templates select="ancestor::liturgicaldays/liturgicalday[name = current()/@name]/daterules/*"/>
  </xsl:template>
  
  <xsl:template match="if">
    <xsl:variable name="test">
      <xsl:apply-templates select="test/*"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$test">
        <xsl:apply-templates select="then/*"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="else/*"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="test-day">
    <!-- tricky: day can be a list of multiple days, e.g. "Saturday Friday Thursday Wednesday"
         and format-date()'s output is contaminated like this: "[Language: en]Wednesday" 
         so a regex is needed to remove the [...]-part from the format-date()-output-->
    <xsl:variable name="date">
      <xsl:apply-templates/>
    </xsl:variable>
    <xsl:variable name="day">
      <xsl:value-of select="replace(format-date(xs:date($date),'[F]'),'(\[.*\])?(.+)','$2')"/>
    </xsl:variable>
    <xsl:if test="matches(day,$day)">true</xsl:if>
  </xsl:template>
  
  <xsl:template match="weekday-after">
    <xsl:variable name="date">
      <xsl:apply-templates/>
    </xsl:variable>
    <!--1/ get weekdayindex of reference date (r) and weekdayindex of target day (t)
        2/ get difference between t and r, d = (max(r,t)-min(r,t))
        3/ add d days to the reference date-->
    <xsl:variable name="weekdayindex">
      <day name="Sunday" index="1"/>
      <day name="Monday" index="2"/>
      <day name="Tuesday" index="3"/>
      <day name="Wednesday" index="4"/>
      <day name="Thursday" index="5"/>
      <day name="Friday" index="6"/>
      <day name="Saturday" index="7"/>
    </xsl:variable>
    <xsl:variable name="r">
      <xsl:value-of select="$weekdayindex/day[matches(replace(format-date(xs:date($date),'[F]'),'(\[.*\])?(.+)','$2'),@name)]/@index"/>
    </xsl:variable>
    <xsl:variable name="t">
      <xsl:value-of select="$weekdayindex/day[matches(current()/@day,@name)]/@index"/>
    </xsl:variable>
    <xsl:variable name="d">
      <xsl:choose>
        <xsl:when test="$r &gt; $t">
          <xsl:value-of select="$t - $r + 7"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$t - $r"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="daysDuration">
      <xsl:text>P</xsl:text>
      <xsl:number value="$d"/>
      <xsl:text>D</xsl:text>
    </xsl:variable>
    <xsl:message><xsl:value-of select="concat($t,'|',$r,'|',$d)"/></xsl:message>
    <date>
      <xsl:value-of select="replace(format-date(xs:date($date) + xs:dayTimeDuration($daysDuration), '[Y0001]-[M01]-[D01]'),'(\[.*\])?(.+)','$2')"/>
    </date>
  </xsl:template>
  
  <xsl:template match="weekday-before">
    <xsl:variable name="daterules">
      <weekday-after day="{@day}">
        <weeks-before nr="1">
          <xsl:apply-templates/>
        </weeks-before>
      </weekday-after>
    </xsl:variable>
    <xsl:apply-templates select="$daterules/*"/>
  </xsl:template>
  
  <xsl:template match="days-before">
    <xsl:variable name="date">
      <xsl:apply-templates/>
    </xsl:variable>
    <xsl:variable name="daysDuration">
      <xsl:text>P</xsl:text>
      <xsl:value-of select="@nr"/>
      <xsl:text>D</xsl:text>
    </xsl:variable>
    <date>
      <xsl:value-of select="replace(format-date(xs:date($date) - xs:dayTimeDuration($daysDuration), '[Y0001]-[M01]-[D01]'),'(\[.*\])?(.+)','$2')"/>
    </date>
  </xsl:template>

  <xsl:template match="days-after">
    <xsl:variable name="date">
      <xsl:apply-templates/>
    </xsl:variable>
    <xsl:variable name="daysDuration">
      <xsl:text>P</xsl:text>
      <xsl:value-of select="@nr"/>
      <xsl:text>D</xsl:text>
    </xsl:variable>
    <date>
      <xsl:value-of select="replace(format-date(xs:date($date) + xs:dayTimeDuration($daysDuration), '[Y0001]-[M01]-[D01]'),'(\[.*\])?(.+)','$2')"/>
    </date>
  </xsl:template>

  <xsl:template match="weeks-before">
    <xsl:variable name="date">
      <xsl:apply-templates/>
    </xsl:variable>
    <xsl:variable name="daysDuration">
      <xsl:text>P</xsl:text>
      <xsl:value-of select="7 * @nr"/>
      <xsl:text>D</xsl:text>
    </xsl:variable>
    <date>
      <xsl:value-of select="replace(format-date(xs:date($date) - xs:dayTimeDuration($daysDuration), '[Y0001]-[M01]-[D01]'),'(\[.*\])?(.+)','$2')"/>
    </date>
  </xsl:template>

  <xsl:template match="weeks-after">
    <xsl:variable name="date">
      <xsl:apply-templates/>
    </xsl:variable>
    <xsl:variable name="daysDuration">
      <xsl:text>P</xsl:text>
      <xsl:value-of select="7 * @nr"/>
      <xsl:text>D</xsl:text>
    </xsl:variable>
    <date>
      <xsl:value-of select="replace(format-date(xs:date($date) + xs:dayTimeDuration($daysDuration), '[Y0001]-[M01]-[D01]'),'(\[.*\])?(.+)','$2')"/>
    </date>
  </xsl:template>
</xsl:stylesheet>
