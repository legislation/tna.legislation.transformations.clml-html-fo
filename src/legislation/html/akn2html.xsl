<?xml version="1.0" encoding="utf-8"?>

<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xpath-default-namespace="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns:uk="https://legislation.gov.uk/akn"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="uk html xs">

<xsl:output method="html" version="5" encoding="utf-8" indent="yes" include-content-type="no" />

<xsl:strip-space elements="*" />
<xsl:preserve-space elements="p block num heading span a date docDate docNumber docTitle docType docStage docProponent time b i u" />

<xsl:param name="image-base" as="xs:string" select="'/'" />

<!-- When non-empty, the head links to an external stylesheet at this URL instead
     of embedding the CSS inline. The CSS body lives in associated-docs.css
     alongside this XSL and is the single source of truth for both modes. -->
	<xsl:param name="stylesheet-href" as="xs:string" select="'/styles/associated-docs.css'" />

<!-- global variables -->

<xsl:variable name="doc-id" as="xs:string">
	<xsl:variable name="work-uri" as="xs:string">
		<xsl:sequence select="/akomaNtoso/*/meta/identification/FRBRWork/FRBRthis/@value" />
	</xsl:variable>
	<xsl:variable name="long-form-prefix" as="xs:string" select="'http://legislation.gov.uk/id/'" />
	<xsl:choose>
		<xsl:when test="starts-with($work-uri, $long-form-prefix)">
			<xsl:sequence select="substring-after($work-uri, $long-form-prefix)" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="$work-uri" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:variable>

<xsl:variable name="parameters" as="document-node()?" select="if (doc-available('input:request')) then doc('input:request') else ()"/>

<!-- templates -->

<xsl:template match="akomaNtoso">
	<html>
		<head>
			<meta charset="utf-8" />
			<xsl:choose>
				<xsl:when test="$stylesheet-href != ''">
					<link rel="stylesheet" href="{$stylesheet-href}" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="style" />
				</xsl:otherwise>
			</xsl:choose>
		</head>
		<body>
			<xsl:call-template name="header"/>
			<xsl:apply-templates />
		</body>
	</html>
</xsl:template>

<xsl:template name="style">
	<style><xsl:text>&#10;</xsl:text><xsl:value-of select="unparsed-text('associated-docs.css')" disable-output-escaping="yes" /><xsl:text>&#10;</xsl:text></style>
</xsl:template>

<xsl:template match="doc">
	<article id="doc" data-doc-type="{@name}">
		<xsl:apply-templates />
		<xsl:call-template name="footnotes" />
	</article>
</xsl:template>

<xsl:template match="attachment/doc">
	<section class="attachment" data-name="{ @name }">
		<xsl:apply-templates />
	</section>
</xsl:template>

<xsl:template match="meta" />

<xsl:template match="preface">
	<div class="{ local-name() }">
		<xsl:apply-templates />
	</div>
</xsl:template>

<xsl:template match="mainBody">
	<div class="body">
		<xsl:apply-templates />
	</div>
</xsl:template>

<xsl:template match="level | section | paragraph | subparagraph | hcontainer">
	<section>
		<xsl:if test="@eId">
			<xsl:attribute name="id" select="@eId" />
		</xsl:if>
		<xsl:attribute name="class">
			<xsl:value-of select="local-name(.)" />
			<xsl:if test="@name">
				<xsl:text> </xsl:text>
				<xsl:value-of select="@name" />
			</xsl:if>
			<xsl:if test="@class">
				<xsl:text> </xsl:text>
				<xsl:value-of select="@class" />
			</xsl:if>
			<xsl:if test="num">
				<xsl:text> num</xsl:text>
			</xsl:if>
			<xsl:if test="heading">
				<xsl:text> heading</xsl:text>
			</xsl:if>
		</xsl:attribute>
		<xsl:if test="(num | heading)[normalize-space(.) != '']">
			<h2>
				<xsl:apply-templates select="num | heading" />
			</h2>
		</xsl:if>
		<xsl:apply-templates select="* except (num, heading)" />
	</section>
</xsl:template>

<xsl:template match="blockContainer">
	<div class="blockContainer">
		<xsl:apply-templates select="* except num" />
	</div>
</xsl:template>

<xsl:template match="blockContainer/p[1]">
	<p>
		<xsl:apply-templates select="preceding-sibling::num" />
		<xsl:apply-templates />
	</p>
</xsl:template>

<!-- content blocks -->

<!-- blocks -->

<xsl:template match="p">
	<xsl:element name="{ local-name() }">
		<xsl:copy-of select="@class" />
		<xsl:if test="@eId">
			<xsl:attribute name="id" select="@eId" />
		</xsl:if>
		<xsl:apply-templates />
	</xsl:element>
</xsl:template>

<xsl:template match="block">
	<p class="@name">
		<xsl:apply-templates />
	</p>
</xsl:template>

<!-- IA cover-sheet sections (class="summary") preserve their visible
     headers as DOCX-styled paragraphs in the body content. The section
     <heading> is needed for AKN structure and TOC but rendering it would
     duplicate the visible header. Other IA sections (e.g. "Declaration",
     numbered chapters) keep their <heading> and render normally. -->

<xsl:template match="doc[@name='ImpactAssessment']//section[contains(concat(' ', @class, ' '), ' summary ')]/heading">
	<!-- Hidden: visible heading lives in the body content. -->
</xsl:template>
<!-- inline -->

<xsl:template match="num | heading | docType | docNumber | docTitle | docStage | docDate | docProponent | date">
	<span class="{ local-name() }">
		<xsl:apply-templates />
	</span>
</xsl:template>

<xsl:template match="span">
	<span>
		<xsl:copy-of select="@*" />
		<xsl:apply-templates />
	</span>
</xsl:template>

<xsl:template match="img">
	<img>
		<xsl:attribute name="src" select="substring-after(@src, 'http://www.legislation.gov.uk')"/>
		<xsl:attribute name="alt" select="(@alt, '')[1]" />
		<xsl:apply-templates />
	</img>
</xsl:template>

<xsl:template match="b | i | u">
	<xsl:element name="{ local-name() }">
		<xsl:copy-of select="@*" />
		<xsl:apply-templates />
	</xsl:element>
</xsl:template>

<xsl:template match="br">
	<br/>
</xsl:template>


<!-- tables -->

<xsl:template match="table">
	<table>
		<xsl:copy-of select="@class | @style" />
		<!-- Add Impact Assessment table class based on context -->
		<xsl:if test="ancestor::doc[@name='ImpactAssessment']">
			<xsl:attribute name="class">
				<xsl:text>ia-table</xsl:text>
				<xsl:if test="@class">
					<xsl:text> </xsl:text>
					<xsl:value-of select="@class" />
				</xsl:if>
			</xsl:attribute>
		</xsl:if>
		<xsl:if test="exists(@uk:widths)">
			<xsl:variable name="widths" as="xs:string*" select="tokenize(@uk:widths, ' ')" />
			<xsl:variable name="total-in" as="xs:double"
				select="sum(for $w in $widths return xs:double(replace($w, '[^0-9.]', '')))" />
			<colgroup>
				<xsl:for-each select="$widths">
					<xsl:variable name="w-in" as="xs:double" select="xs:double(replace(., '[^0-9.]', ''))" />
				<col style="width:{round($w-in div $total-in * 10000) div 100}%" />
				</xsl:for-each>
			</colgroup>
		</xsl:if>
		<tbody>
			<xsl:apply-templates />
		</tbody>
	</table>
</xsl:template>

<xsl:template match="tr | td | th">
	<xsl:element name="{ local-name() }">
		<xsl:copy-of select="@*" />
		<xsl:apply-templates />
	</xsl:element>
</xsl:template>


<!-- links -->

<xsl:template match="a | ref">
	<a>
		<xsl:apply-templates select="@href" />
		<xsl:apply-templates />
	</a>
</xsl:template>


<!-- content organization -->


<!-- markers and attributes -->

<xsl:template match="marker[@name='tab']">
	<span class="tab">&#160;</span>
</xsl:template>

<xsl:template match="@src | @href | @title">
	<xsl:copy />
</xsl:template>


<!-- footnotes -->

<xsl:template match="authorialNote">
	<a class="fn" id="fnref-{@marker}" href="#fn-{@marker}">
		<xsl:value-of select="@marker" />
	</a>
</xsl:template>

<xsl:template name="footnotes">
	<xsl:param name="footnotes" as="element()*" select="descendant::authorialNote" />
	<xsl:if test="exists($footnotes)">
		<footer class="footnotes">
			<hr style="margin-top:2em" />
			<xsl:apply-templates select="$footnotes" mode="footnote" />
		</footer>
	</xsl:if>
</xsl:template>

<xsl:template match="authorialNote" mode="footnote">
	<div class="footnote">
		<xsl:apply-templates />
	</div>
</xsl:template>

<xsl:template match="authorialNote/p[1]">
	<xsl:element name="{ local-name() }">
		<xsl:if test="@class">
			<xsl:attribute name="class" select="@class" />
		</xsl:if>
		<a class="marker" id="fn-{../@marker}" href="#fnref-{../@marker}">
			<xsl:value-of select="../@marker" />
		</a>
		<xsl:text> </xsl:text>
		<xsl:apply-templates />
	</xsl:element>
</xsl:template>

<!-- Drop leading tab markers in the first paragraph of a footnote. Some
     source DOCX files use a tab between the footnote number and text;
     others don't. Suppressing makes spacing consistent. Priority "2"
     wins over the generic marker[@name='tab'] template. -->
<xsl:template match="authorialNote/p[1]/marker[@name='tab'][not(preceding-sibling::node()[normalize-space()])]" priority="2" />

<!-- Auto-link bare URLs in footnote text. Skip text that's already inside
     an <a> in the source AKN — wrapping it again produces nested <a>s,
     which are invalid HTML. -->
<xsl:template match="authorialNote//text()[not(ancestor::a)]">
	<xsl:analyze-string select="." regex="https?://[^\s&lt;&gt;]+">
		<xsl:matching-substring>
			<a href="{.}"><xsl:value-of select="." /></a>
		</xsl:matching-substring>
		<xsl:non-matching-substring>
			<xsl:value-of select="." />
		</xsl:non-matching-substring>
	</xsl:analyze-string>
</xsl:template>

<xsl:template match="toc"></xsl:template>

<!--[ TOC Link Header ]-->
	<xsl:template name="header">
		<xsl:variable name="p" select="$parameters/*:parameters"/>
		<xsl:variable name="section" select="$p/*:section"/>
		<xsl:variable name="prev" select="substring-after(//atom:link[@rel='prev'][1]/@href, 'http://www.legislation.gov.uk')"/>
		<xsl:variable name="next" select="substring-after(//atom:link[@rel='next'][1]/@href, 'http://www.legislation.gov.uk')"/>
		<xsl:variable name="full-view" select="concat($doc-id, '/data.html')"/>

		<xsl:variable name="is-section-view" select="$section != ''"/>
		<xsl:variable name="has-prev" select="$prev != '' and $prev != $doc-id"/>
		<xsl:variable name="has-next" select="$next != ''"/>

		<xsl:variable name="uri-path" as="xs:string">
			<xsl:choose>
				<xsl:when test="$p/*:IA = 'yes' and $p/*:type != ''">
					<xsl:sequence select="
						string-join(
						($p/*:type,
						$p/*:year,
						$p/*:number,
						'impacts',
						$p/*:impactyear,
						$p/*:impactnumber,
						'contents'),
						'/'
						)"/>
				</xsl:when>
				<xsl:when test="$p/*:IA = 'yes'">
					<xsl:sequence select="
						string-join(
						($p/*:impacttype,
						$p/*:impactyear,
						$p/*:impactnumber,
						'contents'),
						'/'
						)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="concat($doc-id, '/contents')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<header class="toc-header">
			<a class="toc-link" href="{normalize-space($uri-path)}">Back to Table of Contents</a>
			<nav class="section-nav">
				<!-- Disabled placeholders. Frontend hooks them up to point at
			     the previous/next section's URL when those views exist. -->

				<!-- Previous -->
				<xsl:choose>
					<xsl:when test="$has-prev">
						<a class="section-link prev-section"
							href="{$prev}/data.html">
							<xsl:text>Previous section</xsl:text>
						</a>
					</xsl:when>
					<xsl:otherwise>
						<a class="section-link prev-section disabled" aria-disabled="true">
							<xsl:text>Previous section</xsl:text>
						</a>
					</xsl:otherwise>
				</xsl:choose>

				<!-- Next -->
				<xsl:choose>
					<xsl:when test="$has-next">
						<a class="section-link next-section" href="{$next}/data.html">
							<xsl:text>Next section</xsl:text>
						</a>
					</xsl:when>
					<xsl:otherwise>
						<a class="section-link next-section disabled"
							aria-disabled="true">
							<xsl:text>Next section</xsl:text>
						</a>
					</xsl:otherwise>
				</xsl:choose>
			</nav>
			<!-- Back to full view: disabled on the whole-doc HTML (you are
		     already on full view); frontend activates it on section views. -->
			<xsl:choose>
				<xsl:when test="$is-section-view">
					<a class="full-view-link" href="{$full-view}">
						<xsl:text>Back to full view</xsl:text>
					</a>
				</xsl:when>
				<xsl:otherwise>
					<a class="full-view-link disabled" aria-disabled="true">
						<xsl:text>Back to full view</xsl:text>
					</a>
				</xsl:otherwise>
			</xsl:choose>
		</header>

	</xsl:template>

<!-- end of templates -->

</xsl:transform>
