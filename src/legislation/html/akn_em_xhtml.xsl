<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright

You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0

http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

-->
<!-- UI EN Table of Content/Content page output  -->

<!-- Version 0.01 -->
<!-- Created by Faiz Muhammad -->
<!-- Last changed 01/03/2010 by Faiz Muhammad -->
<!-- Change history

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns="http://www.w3.org/1999/xhtml" version="2.0" xmlns:xhtml="http://www.w3.org/1999/xhtml"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:tso="http://www.tso.co.uk/assets/namespaces/functions"
	xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:db="http://docbook.org/ns/docbook"
	xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
	xmlns:atom="http://www.w3.org/2005/Atom"
	xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:xforms="http://www.w3.org/2002/xforms"
	xmlns:akn="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns:ev="http://www.w3.org/2001/xml-events">

	<xsl:import href="en_xhtml.xsl"/>

	<xsl:variable name="aknDoc" as="document-node()?" select="
			if (doc-available('input:aknData')) then
				doc('input:aknData')
			else
				()"/>

	<xsl:template name="TSOOutputLegislationContent">
		<div id="viewLegContents">
			<div class="LegSnippet" xml:lang="{$language}">
				<xsl:choose>
					<xsl:when
						test="$paramsDoc/parameters/view = 'contents' and $paramsDoc/parameters/notes-type = 'memorandum'">
						<xsl:if test="$aknDoc//akn:toc">
							<xsl:attribute name="id">tocControlsAdded</xsl:attribute>
						</xsl:if>
						<div class="LegContents LegClearFix">
							<ol>
								<xsl:apply-templates select="$aknDoc//akn:toc" mode="toc"/>
							</ol>
						</div>
					</xsl:when>
					<xsl:when test="leg:IsEnPDFOnly(.)">
						<!-- If EN/EM is only available in PDFOnly then display PDF link -->
						<p class="downloadPdfVersion">
							<xsl:variable name="pdfLinks"
								select="/leg:EN/ukm:Metadata/ukm:Alternatives/ukm:Alternative[contains(@URI, concat($enType, '_'))]"/>
							<xsl:variable name="pdfLinks" select="
									if ($documentMainType = $welshDocumentMainTypes) then
										if ($isReferrerWelsh) then
											$pdfLinks[@Language = 'Welsh']
										else
											$pdfLinks[not(@Language)]
									else
										if (exists($pdfLinks[contains(@Title, 'Revised')])) then
											$pdfLinks[contains(@Title, 'Revised')]
										else
											$pdfLinks"> </xsl:variable>

							<xsl:choose>
								<xsl:when test="count($pdfLinks) > 1">
									<!-- if there are multiple PDFs and then add a span around it so that they are displayed in two columns-->
									<span>
										<xsl:apply-templates select="$pdfLinks" mode="PDFOnly"/>
									</span>
								</xsl:when>
								<xsl:otherwise>
									<xsl:apply-templates select="$pdfLinks" mode="PDFOnly"/>
								</xsl:otherwise>
							</xsl:choose>
						</p>

					</xsl:when>
					<xsl:otherwise>
						<!-- adding the tocControlsAddress to the table of contents when it is not PDFOnly-->
						<xsl:if
							test="count(//leg:ContentsDivision[* except (leg:ContentsNumber, leg:ContentsTitle)]) > 0">
							<xsl:attribute name="id">tocControlsAdded</xsl:attribute>
						</xsl:if>

						<!-- output the legislation content-->
						<!--<xsl:call-template name="TSOOutputContent"/>-->
					</xsl:otherwise>
				</xsl:choose>
			</div>
		</div>

	</xsl:template>

	<xsl:template match="akn:tocItem" mode="toc">
		<xsl:variable name="link" select="concat(@href, '/data.html')"/>
		<xsl:variable name="level" select="@level"/>
		<xsl:variable name="indent" select="
				if ($level castable as xs:integer) then
					(concat('margin-left: ', $level, 'em'))
				else
					'margin-left: 0em'"/>
		<xsl:variable name="label">
			<!--<xsl:value-of select="tso:extract-label($url)"/>-->
		</xsl:variable>
		<xsl:variable name="title" select="akn:inline[@name = 'tocHeading']"/>

		<li class="LegContentsEntry" style="{$indent} !important">
			<p class="LegContentsItem">
				<span class="LegDS LegContentsTitle">
					<a href="{$link}">
						<xsl:value-of select="$title"/>
					</a>
				</span>
			</p>
		</li>
	</xsl:template>
</xsl:stylesheet>
