<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright

You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0

http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns="http://www.w3.org/1999/xhtml" version="2.0" xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:tso="http://www.tso.co.uk/assets/namespaces/functions"
	xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:db="http://docbook.org/ns/docbook"
	xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
	xmlns:atom="http://www.w3.org/2005/Atom"
	xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:xforms="http://www.w3.org/2002/xforms" xmlns:ev="http://www.w3.org/2001/xml-events"
	xmlns:uk="https://legislation.gov.uk/akn"
	xmlns:akn="http://docs.oasis-open.org/legaldocml/ns/akn/3.0">

	<xsl:import href="impacts_xhtml.xsl"/>

	<xsl:variable name="stages" as="xs:string*" select="
			('consultation', 'development', 'enactment', 'final',
			'implementation', 'options', 'post-implementation')"/>

	<xsl:variable name="associated-doc-types" as="xs:string*" select="
			('code-of-conduct', 'code-of-practice', 'draft-policy-note',
			'equality-impact-assessment', 'explanatory-document',
			'impact-assessment', 'ni-draft-explanatory-memorandum',
			'ni-explanatory-memorandum', 'other-document',
			'policy-equality-statement', 'policy-note',
			'revised-policy-note', 'revised-uk-explanatory-memorandum',
			'revised-welsh-explanatory-memorandum', 'transposition-note',
			'uk-draft-explanatory-memorandum', 'uk-explanatory-memorandum',
			'uk-rpc-opinion', 'welsh-explanatory-memorandum')"/>

	<xsl:variable name="pattern" select="string-join(($stages, $associated-doc-types), '|')"/>

	<xsl:variable name="aknDoc" as="document-node()?" select="
			if (doc-available('input:aknData')) then
				doc('input:aknData')
			else
				()"/>

	<xsl:variable name="collection" as="document-node()?" select="
			if (doc-available('input:collection')) then
				doc('input:collection')
			else
				()"/>

	<xsl:variable name="iaStage" as="xs:string?" select="$aknDoc//akn:meta/akn:proprietary/ukm:DocumentStage/@Value"/>

	<xsl:template match="/">
		<xsl:choose>
			<xsl:when
				test="($paramsDoc/parameters/view = 'contents') and ($paramsDoc/parameters/format = 'html')">
				<xsl:apply-templates select="$aknDoc" mode="plain-html"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-imports/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="leg:ImpactAssessment" mode="TSOOutputLegislationContent">

		<xsl:variable name="version" as="xs:string?">
			<xsl:value-of>
				<xsl:value-of select="leg:TranslateText('the')"/>
				<xsl:text> </xsl:text>
				<xsl:value-of select="
						leg:TranslateText(if ($iaStage != '') then
							translate($iaStage, '-', ' ')
						else
							'Final')"/>
				<xsl:text> </xsl:text>
				<xsl:value-of select="leg:TranslateText('version of the')"/>
				<xsl:text> </xsl:text>
			</xsl:value-of>
		</xsl:variable>

		<div id="infoSection-status">
			<h2><xsl:value-of select="leg:TranslateText('Status')"/>:</h2>
			<p class="intro">
				<xsl:value-of
					select="leg:TranslateText('Ia_status_message', concat('version=', $version))"/>
			</p>
		</div>

		<div id="viewLegContents">
			<div class="LegSnippet" id="viewLegSnippet">
				<div class="LegContents LegClearFix">
					<ol>
						<xsl:call-template name="toc-link-whole-html-page"/>
						<xsl:apply-templates select="$aknDoc//akn:toc" mode="toc"/>
					</ol>
				</div>
			</div>
		</div>

		<div class="contentFooter">
			<div class="interface"/>
		</div>

	</xsl:template>

	<xsl:template match="akn:tocItem" mode="toc">
		<xsl:variable name="url" select="substring-after(@href, 'http://www.legislation.gov.uk')"/>
		<xsl:variable name="link">
			<xsl:value-of select="concat(replace($url, '//+', '/'), '/data.html')"/>
		</xsl:variable>
		<xsl:variable name="level" select="@level"/>
		<xsl:variable name="indent" select="if ($level castable as xs:integer) then (concat('margin-left: ', $level, 'em')) else 'margin-left: 0em'"/>
		<xsl:variable name="label">
			<!--<xsl:value-of select="tso:extract-label($url)"/>-->
		</xsl:variable>
		<xsl:variable name="title" select="akn:inline[@name = 'tocHeading']"/>

		<li class="LegContentsEntry" style="{$indent} !important">
			<p class="LegContentsItem LegClearFix">
				<!--<span class="LegDS LegContentsNo">
					<a href="{$link}">
						<xsl:value-of select="$label"/>
					</a>
				</span>-->
				<span class="LegDS LegContentsTitle">
					<a href="{$link}">
						<xsl:value-of select="leg:truncate-text($title, 100)"/>
					</a>
				</span>
			</p>
		</li>
	</xsl:template>

	<xsl:template name="toc-link-whole-html-page">
		<xsl:variable name="url" select="substring-after($aknDoc//akn:FRBRWork/akn:FRBRuri[1]/@value, 'http://www.legislation.gov.uk/id')"/>
		<xsl:variable name="link">
			<xsl:value-of select="concat(replace($url, '//+', '/'), '/data.html')"/>
		</xsl:variable>
		<xsl:variable name="indent" select="'margin-left: 1em'"/>

		<xsl:variable name="title">
			<xsl:choose>
				<xsl:when test="$paramsDoc/parameters/IA = 'yes'">
					<xsl:text>The whole Impact Assessment</xsl:text>
				</xsl:when>
				<xsl:when test="$paramsDoc/parameters/notes-type = 'memorandum'">
					<xsl:text>The whole Explanatory Memorandum</xsl:text>
				</xsl:when>
				<xsl:when test="$paramsDoc/parameters/notes-type = 'notes'">
					<xsl:text>The whole Explanatory Note</xsl:text>
				</xsl:when>
				<xsl:when test="$paramsDoc/parameters/notes-type = 'transposition-note'">
					<xsl:text>The whole Transposition Note</xsl:text>
				</xsl:when>
				<xsl:when test="$paramsDoc/parameters/notes-type = 'other-document'">
					<xsl:text>The whole Other Document</xsl:text>
				</xsl:when>
				<xsl:when test="$paramsDoc/parameters/notes-type = 'code-of-practice'">
					<xsl:text>The whole Code of Practice</xsl:text>
				</xsl:when>
				<!--<xsl:otherwise>
					<xsl:text>No title</xsl:text>
				</xsl:otherwise>-->
			</xsl:choose>
		</xsl:variable>

		<li class="LegContentsEntry" style="{$indent} !important">
			<p class="LegContentsItem LegClearFix">
				<span class="LegDS LegContentsNo"/>
				<span class="LegDS LegContentsTitle">
					<a href="{$link}">
						<xsl:value-of select="$title"/>
					</a>
				</span>
			</p>
		</li>
	</xsl:template>

</xsl:stylesheet>
