<?xml version="1.0"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" indent="yes"/>
  <xsl:template match="liturgicaldays">
    <xsl:copy>
      <xsl:comment>
        obtain below data live on this URL:  

http://services.w3.org/xslt?xslfile=https%3A%2F%2Fraw.github.com%2Fvicmortelmans%2FBibleConfiguration%2Fmaster%2Fliturgy.calendar_unfolding_parametrized_rulesets.xslt&amp;xmlfile=https%3A%2F%2Fraw.github.com%2Fvicmortelmans%2FBibleConfiguration%2Fmaster%2Fliturgy.calendar.roman-rite.ruleset.xml&amp;content-type=&amp;submit=transform

or by using this command:

java net.sf.saxon.Transform -s:liturgy.calendar.roman-rite.ruleset.xml -xsl:liturgy.calendar_unfolding_para metrized_rulesets.xslt -o:liturgy.calendar.roman-rite.ruleset.unfolded.xml
       </xsl:comment>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="coordinaterules">
    <xsl:copy-of select="."/>
  </xsl:template>
  
  <xsl:template match="liturgicalday">
    <xsl:message>Processing set <xsl:value-of select="template/set"/></xsl:message>
    <xsl:if test="parameters">
      <xsl:variable name="liturgicalday" select="."/>
      <xsl:variable name="parameters">
        <xsl:apply-templates select="parameters"/>
      </xsl:variable>
      <xsl:for-each select="$parameters/parametergroup">
        <liturgicalday>
          <xsl:apply-templates select="$liturgicalday/template/*" mode="fill-in">
            <xsl:with-param name="parametergroup" select="."/>
          </xsl:apply-templates>
        </liturgicalday>
      </xsl:for-each>
    </xsl:if>
    <xsl:if test="not(parameters)">
      <liturgicalday>
        <xsl:copy-of select="template/*"/>
      </liturgicalday>
    </xsl:if>
  </xsl:template>

  <!-- FLATTENING MULTIPLE LEVELS OF PARAMETRIZATION -->
  <xsl:template match="parameters">
    <xsl:param name="accuparametergroup"/>
    <xsl:for-each select="parametergroup">
      <xsl:if test="../parameters">
        <xsl:apply-templates select="../parameters">
          <xsl:with-param name="accuparametergroup">
            <xsl:copy-of select="$accuparametergroup"/>
            <xsl:copy-of select="*"/>
          </xsl:with-param>
        </xsl:apply-templates>
      </xsl:if>
      <xsl:if test="not(../parameters)">
        <parametergroup>
          <xsl:copy-of select="$accuparametergroup"/>
          <xsl:copy-of select="*"/>
        </parametergroup>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!-- FILLING IN THE PARAMETERS INTO THE TEMPLATE -->
  <xsl:template match="node()" mode="fill-in">
    <xsl:param name="parametergroup"/>
    <xsl:copy>
      <xsl:apply-templates select="attribute::node()|child::node()" mode="fill-in">
        <xsl:with-param name="parametergroup" select="$parametergroup"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <xsl:template name="replace">
    <xsl:param name="string"/>
    <xsl:param name="parametergroup"/>
    <xsl:choose>
      <xsl:when test="not(normalize-space($parametergroup)) or not(matches($string,'\$'))">
        <xsl:value-of select="$string"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="replace">
          <xsl:with-param name="string" select="replace($string,concat('\$',local-name($parametergroup/*[1])),$parametergroup/*[1])"/>
          <xsl:with-param name="parametergroup">
            <xsl:copy-of select="$parametergroup/*[position() &gt; 1]"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="text()" mode="fill-in" priority="2">
    <xsl:param name="parametergroup"/>
    <xsl:call-template name="replace">
      <xsl:with-param name="string" select="."/>
      <xsl:with-param name="parametergroup" select="$parametergroup"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="attribute::node()" mode="fill-in" priority="2">
    <xsl:param name="parametergroup"/>
    <xsl:attribute name="{local-name(.)}">
      <xsl:call-template name="replace">
        <xsl:with-param name="string" select="."/>
        <xsl:with-param name="parametergroup" select="$parametergroup"/>
      </xsl:call-template>
    </xsl:attribute>
  </xsl:template>
</xsl:stylesheet>
