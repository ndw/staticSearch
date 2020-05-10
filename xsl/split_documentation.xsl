<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:hcmc="http://hcmc.uvic.ca/ns"
    xpath-default-namespace="http://www.w3.org/1999/xhtml"
    xmlns="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="#all"
    version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> May 09, 2018</xd:p>
            <xd:p><xd:b>Author:</xd:b> jtakeda</xd:p>
            <xd:p>This transformation takes the big documentation document produced by spiffing up the standard TEI documentation and creates chapters from it. It also creates a TOC sidebar on the side and adds a search page to the front.</xd:p>
        </xd:desc>
    </xd:doc>
    

    <xsl:output method="xhtml" html-version="5.0" encoding="UTF-8" indent="yes" omit-xml-declaration="yes"/>
    
    <xsl:variable name="toc" select="//div[@class='tei_front']" as="element(div)"/>
    
    <xsl:variable name="thisDir" select="document-uri(/)"/>
    
    <xsl:variable name="docSections" select="//section"/>
    
    
    <xd:doc>
        <xd:desc>Root template, which processes through the document first through 
        the index template, and then processes the document through the section template for each section.</xd:desc>
    </xd:doc>
    <xsl:template match="/">
        <xsl:variable name="doc" select="html"/>
        <xsl:apply-templates select="$doc" mode="index"/>

        <xsl:for-each select="$docSections">
            <xsl:apply-templates select="$doc" mode="section">
                <xsl:with-param name="section" tunnel="yes" select="."/>
            </xsl:apply-templates>
        </xsl:for-each>
    </xsl:template>
    
    
   
    
    <!--INDEX TEMPLATES-->
    
    <xd:doc>
        <xd:desc>Create a new HTML with the new out path as the index.</xd:desc>
    </xd:doc>
    <xsl:template match="html" mode="index">
        <xsl:result-document href="{replace($thisDir,'[^/]+\.html','index.html')}">
            <xsl:copy>
                <xsl:apply-templates select="@*|node()" mode="#current"/>
            </xsl:copy>
        </xsl:result-document>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Create the new id for it.</xd:desc>
    </xd:doc>
    <xsl:template match="html/@id" mode="index">
        <xsl:attribute name="id" select="'index'"/>
    </xsl:template>
    
    
 
    
    
    
    <xd:doc>
        <xd:desc>Place the document title into the body, and add the staticSearch div.</xd:desc>
    </xd:doc>
    <xsl:template match="div[contains-token(@class,'tei_body')]" mode="index">
        <div>
            <xsl:apply-templates select="@*"/>
            <xsl:copy-of select="ancestor::html/descendant::div[contains-token(@class,'docTitle')]"/>
            <div id="staticSearch"/>
            
        </div>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Delete the back from all documents.</xd:desc>
    </xd:doc>
    <xsl:template match="div[contains-token(@class,'tei_back')]" mode="index section"/>
    
    <xd:doc>
        <xd:desc>For all documents: Add a new CSS stylesheet for some small overrides</xd:desc>
    </xd:doc>
    <xsl:template match="link[@rel='stylesheet'][1]" mode="index section">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="#current"/>
        </xsl:copy>
        <link rel="stylesheet" type="text/css" href="doc_chapters.css"/>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>For all documents: Make the main title on the side bar an index link</xd:desc>
    </xd:doc>
    <xsl:template match="div[contains-token(@class,'titlePart')][1]" mode="index section">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <a href="index.html"><xsl:apply-templates select="node()" mode="#current"/></a>
        </xsl:copy>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>For all documents: Add a wrapper to the TOC stuff for styling.</xd:desc>
    </xd:doc>
    <xsl:template match="div[contains-token(@class,'tei_front')]" mode="index section">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <div>
                <xsl:apply-templates select="node()" mode="#current"/>
            </div>
        </xsl:copy>
    </xsl:template>
    
    <!--SECTION TEMPLATES-->
    
    <xd:doc>
        <xd:desc>Create the HTML shells for each section.</xd:desc>
    </xd:doc>
    <xsl:template match="html" mode="section">
        <xsl:param name="section" tunnel="yes"/>
        <xsl:message>Creating document <xsl:value-of select="replace($thisDir,'[^/]+\.html',$section/@id || '.html')"/></xsl:message>
        <xsl:result-document href="{replace($thisDir,'[^/]+\.html',$section/@id || '.html')}">
            <xsl:copy>
                <xsl:apply-templates select="@*|node()" mode="#current"/>
            </xsl:copy>
        </xsl:result-document>
    </xsl:template>
    
    
    
    <xsl:template match="html/head" mode="section">
        <xsl:param name="section" tunnel="yes"/>
        <xsl:variable name="info" select="$section/ul[preceding-sibling::*[1]/self::header][1]" as="element(ul)?"/>
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="#current"/>
            <!--Now create the meta tags for static search-->
            <xsl:if test="$info">
                <meta name="Date Updated" class="staticSearch.date" content="{hcmc:getDate($info/li/span[@class='date']/text())}"/>
                <meta name="Level" class="staticSearch.desc" content="{$info/li[not(span)]/normalize-space(replace(text(),'Level\s*:\s*',''))}"/>
            </xsl:if>
     
        </xsl:copy>
    </xsl:template>
    
    
    
    <xd:doc>
        <xd:desc>Convert the doc title into something a bit better</xd:desc>
    </xd:doc>
    <xsl:template match="html/head/title" mode="section">
        <xsl:param name="section" tunnel="yes"/>
        <xsl:copy>Static Search: <xsl:value-of select="string-join($section/header/h2/span[@class='head'],'')"/></xsl:copy>
    </xsl:template>
    
    
    <xd:doc>
        <xd:desc>Change the id for sections to the section's id</xd:desc>
    </xd:doc>
    <xsl:template match="html/@id" mode="section">
        <xsl:param name="section" tunnel="yes"/>
        <xsl:attribute name="id" select="$section/@id"/>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Template to add the data-section attribute to the tei body to help with targetting
        specific styling.</xd:desc>
    </xd:doc>
    <xsl:template match="div[contains-token(@class,'tei_body')]" mode="section">
        <xsl:param name="section" tunnel="yes"/>
        <xsl:copy>
            <xsl:attribute name="data-section" select="$section/@id"/>
            <xsl:apply-templates select="@*|node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    
    
    <xd:doc>
        <xd:desc>If this section is the one that we're currently processing, then process its contents;
        otherwise, just ignore it.</xd:desc>
    </xd:doc>
    <xsl:template match="section" mode="section">
        <xsl:param name="section" tunnel="yes"/>
        <xsl:choose>
            <!--If we're processing the schemaSpec, then just inject it as a section in the body-->
            <xsl:when test="$section/@id = 'schemaSpec' and $docSections[1] is .">
                <xsl:apply-templates select="$section" mode="#current"/>
            </xsl:when>
            <xsl:when test=". is $section">
                <xsl:apply-templates mode="#current"/>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
        
    </xsl:template>
    

    
    <xd:doc>
        <xd:desc>Change the h1 of the page to the Chapter title.</xd:desc>
    </xd:doc>
    <xsl:template match="h1" mode="section">
        <xsl:param name="section" tunnel="yes"/>
        
        <!--And create a navigation bar-->
        <xsl:variable name="precedingSection" select="$section/preceding-sibling::section[1]"/>
        <xsl:variable name="followingSection" select="$section/following-sibling::section[1]"/>
        <nav>
            <ul>
                <li class="prev">
                    <xsl:if test="$precedingSection">
                        <a href="{$precedingSection/@id}.html"><xsl:sequence select="$precedingSection/header/h2/node()"/></a>
                    </xsl:if>
                </li>
                <li class="next">
                    <xsl:if test="$followingSection">
                        <a href="{$followingSection/@id}.html">
                            <xsl:sequence select="$followingSection/header/h2/node()"/>
                        </a>
                    </xsl:if>
                </li>
            </ul>
        </nav>
        
        <xsl:copy>
            <xsl:apply-templates select="$section/header/h2/node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Remove the header.</xd:desc>
    </xd:doc>
    <xsl:template match="section/header" mode="section"/>
    
    
    
    <xd:doc>
        <xd:desc>Handle the links.</xd:desc>
    </xd:doc>
    <xsl:template match="a[starts-with(@href,'#')]" mode="section index">
        <xsl:param name="section" tunnel="yes" as="element()?"/>
        <xsl:variable name="ptr" select="substring-after(@href,'#')"/>
        <xsl:variable name="otherSections" 
            select="if (exists($section)) then ($docSections except $section) else $docSections"/>
        <xsl:choose>
            
            <!--Convert feedback link, which doesn't actually work anywhere,
                to point back to the src repo-->
            <xsl:when test="text()='Feedback'">
                <a href="https://github.com/projectEndings/staticSearch">Github</a>
            </xsl:when>
            
            <!--When this points to this div-->
            <xsl:when test="$section/@id = $ptr">
                <span class="current">
                    <xsl:apply-templates mode="#current"/>
                </span>
            </xsl:when>
            
            <!--When this points elsewhere but in this div-->
            <xsl:when test="$section/descendant::*/@id = $ptr">
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()" mode="#current"/>
                </xsl:copy>
            </xsl:when>
            
            <!--When it points to another section-->
            <xsl:when test="ancestor::body/descendant::section/@id = $ptr">
                <xsl:copy>
                    <xsl:attribute name="href" select="$ptr || '.html'"/>
                    <xsl:apply-templates select="@*[not(local-name()='href')] | node()" mode="#current"/>
                
                </xsl:copy>
            </xsl:when>
            
            <!--When it points to another id in a section-->
            <xsl:when test="$otherSections/descendant::*/@id = $ptr">
                <xsl:variable name="thisThing" 
                    select="$otherSections/descendant::*[@id = $ptr]"/>
                <xsl:variable name="thisThingsSection" select="$thisThing/ancestor::section[1]"/>
                <xsl:copy>
                    <xsl:attribute name="href" select="$thisThingsSection/@id || '.html#' || $ptr"/>
                    <xsl:apply-templates select="@*[not(local-name()='href')]|node()" mode="#current"/>
                </xsl:copy>
            </xsl:when>

        </xsl:choose>
    </xsl:template>
    
    
    <xd:doc>
        <xd:desc>Standard identity transform.</xd:desc>
    </xd:doc>
    <xsl:template match="@*|node()" mode="#all" priority="-1">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>


<xd:doc>
    <xd:desc>This function takes a date formatted like 8 May 2019, and turns it into a proper W3C 2019-05-08 date.</xd:desc>
    <xd:param>The input string, hopefully formated something like 08 May 2019.</xd:param>
    <xd:return>A proper YYYY-MM-DD string.</xd:return>
</xd:doc>
<xsl:function name="hcmc:getDate">
    <xsl:param name="str"/>
    <!--Clean up and then tokenize the input string-->
    <xsl:variable name="bits" select="tokenize(translate($str,',.',''),'\s+')"/>
    <xsl:variable name="day" select="$bits[1] => xs:integer() => format-number('00')"/>
    <xsl:message>Processing <xsl:value-of select="$str"/></xsl:message>
    <xsl:variable name="year" select="$bits[3]"/>
    <xsl:variable name="month" select="lower-case($bits[2])"/>
    <xsl:variable name="monthNum" as="xs:string">
        <xsl:choose>
            <!--We have to iterate through the month numbers and determine the number;
                these are the minimal strings necessary to determine what month it is.
                We assume no one is using odd abbreviations or anything like that. It would be
                nice if we could use actual date that is processed, but the TEI stylesheets
                simply removes them.-->
            <xsl:when test="starts-with($month, 'ja')">01</xsl:when>
            <xsl:when test="starts-with($month,'f')">02</xsl:when>
            <xsl:when test="starts-with($month, 'mar')">03</xsl:when>
            <xsl:when test="starts-with($month,'ap')">04</xsl:when>
            <xsl:when test="starts-with($month,'may')">05</xsl:when>
            <xsl:when test="starts-with($month, 'jun')">06</xsl:when>
            <xsl:when test="starts-with($month, 'jul')">07</xsl:when>
            <xsl:when test="starts-with($month, 'au')">08</xsl:when>
            <xsl:when test="starts-with($month,'s')">09</xsl:when>
            <xsl:when test="starts-with($month,'o')">10</xsl:when>
            <xsl:when test="starts-with($month,'n')">11</xsl:when>
            <xsl:when test="starts-with($month,'d')">12</xsl:when>
        </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="string-join(($year,$monthNum,$day),'-')"/>
</xsl:function>
    
    
    
</xsl:stylesheet>