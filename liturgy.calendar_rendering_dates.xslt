<?xml version="1.0"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema">
  <xsl:output method="xml" indent="yes"/>
  <xsl:param name="year"/>
  <xsl:variable name="easterdates" select="document('liturgy.calendar.roman-rite.easterdates.xml')/easterdates"/>
  <xsl:template match="liturgicaldays">
    <xsl:copy>
      <xsl:for-each-group select="liturgicalday" group-by="precedence">
        <xsl:sort select="precedence"/>
        <xsl:for-each select="current-group()">
          <liturgicalday>
            <xsl:copy-of select="*[not(matches(local-name(),'daterules'))]"/>
            <xsl:apply-templates select="daterules/*"/>
          </liturgicalday>
        </xsl:for-each>
      </xsl:for-each-group>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="date">
    <!--in principle, it can be that some 'date' around 1/12 would occur twice in 
        one liturgical year, so a feast on that date should appear twice in 
        the calendar
        Advent starts on the Sunday between November 27 and December 3 inclusive
        Depending on which day Christmas falls, the starting date for Advent is known-->
    <xsl:variable name="advent">
      <start christmas="Sunday" date=""/>
      <start christmas="Monday" date=""/>
      <start christmas="Tuesday" date=""/>
      <start christmas="Wednesday" date=""/>
      <start christmas="Thursday" date=""/>
      <start christmas="Friday" date=""/>
      <start christmas="Saturday" date=""/>
    </xsl:variable>
    <xsl:variable name="firstday">
      
    </xsl:variable>
    <xsl:value-of select="$year"/>
    <xsl:text>-</xsl:text>
    <xsl:value-of select="month"/>
    <xsl:text>-</xsl:text>
    <xsl:value-of select="day"/>
  </xsl:template>
  
  <xsl:template match="easterdate">
    <!-- using $year is OK, easter never falls before 1/1 -->
    <xsl:value-of select="$year"/>
    <xsl:text>-</xsl:text>
    <xsl:value-of select="$easterdates/easterdate[year=$year]/month"/>
    <xsl:text>-</xsl:text>
    <xsl:value-of select="$easterdates/easterdate[year=$year]/day"/>
  </xsl:template>
  
  <xsl:template match="relative-to">
    <xsl:apply-templates select="ancestor::stylesheets/stylesheet[matches(name,$name)]/daterules/*"/>
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
      <xsl:value-of select="$weekdayindex/day[matches(format-date(xs:date($date),'[F]'),@name)]/@index"/>
    </xsl:variable>
    <xsl:variable name="t">
      <xsl:value-of select="$weekdayindex/day[matches(@name,day)]/@index"/>
    </xsl:variable>
    <xsl:variable name="d">
      <xsl:choose>
        <xsl:when test="r &gt; t">
          <xsl:value-of select="r - t"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="t - r"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="daysDuration">
      <xsl:text>P</xsl:text>
      <xsl:value-of select="@d"/>
      <xsl:text>D</xsl:text>
    </xsl:variable>
    <xsl:value-of select="xs:date($date) + xs:dayTimeDuration($daysDuration)"/>
  </xsl:template>
  
  <xsl:template match="weekday-before">
    <xsl:variable name="daterules">
      <weekday-after day="{$day}">
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
    <xsl:value-of select="xs:date($date) - xs:dayTimeDuration($daysDuration)"/>
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
    <xsl:value-of select="xs:date($date) + xs:dayTimeDuration($daysDuration)"/>
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
    <xsl:value-of select="xs:date($date) - xs:dayTimeDuration($daysDuration)"/>
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
    <xsl:value-of select="xs:date($date) + xs:dayTimeDuration($daysDuration)"/>
  </xsl:template>
</xsl:stylesheet>
