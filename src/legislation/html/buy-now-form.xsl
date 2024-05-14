<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright

You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0

http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns="http://www.w3.org/1999/xhtml" xmlns:xhtml="http://www.w3.org/1999/xhtml"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:tso="http://www.tso.co.uk/assets/namespaces/functions"
	xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:db="http://docbook.org/ns/docbook"
	xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
	xmlns:dct="http://purl.org/dc/terms/" xmlns:atom="http://www.w3.org/2005/Atom"
	xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:xforms="http://www.w3.org/2002/xforms" xmlns:ev="http://www.w3.org/2001/xml-events"
	version="2.0">

	<xsl:import href="statuswarning.xsl"/>
	<xsl:import href="legislation_xhtml_consolidation.xslt"/>
	<xsl:import href="quicksearch.xsl"/>
	<xsl:import href="uicommon.xsl"/>

	<xsl:output indent="yes" method="xhtml"/>

	<xsl:variable name="language" select="
			if (/leg:Legislation/@xml:lang) then
				/leg:Legislation/@xml:lang
			else
				'en'"/>

	<xsl:variable name="tocURI" as="xs:string?" select="
		if (/leg:Legislation/ukm:Metadata/atom:link[@rel = 'http://purl.org/dc/terms/tableOfContents'][@hreflang = 'cy'] and $language = 'cy') then
		/leg:Legislation/ukm:Metadata/atom:link[@rel = 'http://purl.org/dc/terms/tableOfContents'][@hreflang = 'cy']/@href
		else if (/leg:Legislation/ukm:Metadata/atom:link[@rel = 'http://purl.org/dc/terms/tableOfContents'][@hreflang = 'en']) then
		/leg:Legislation/ukm:Metadata/atom:link[@rel = 'http://purl.org/dc/terms/tableOfContents'][@hreflang = 'en']/@href
		else if (/leg:Legislation/ukm:Metadata/atom:link[@rel = 'http://purl.org/dc/terms/tableOfContents']) then
		/leg:Legislation/ukm:Metadata/atom:link[@rel = 'http://purl.org/dc/terms/tableOfContents'][1]/@href
		else
		/leg:Legislation/@DocumentURI"/>
	
	<xsl:variable name="resourceURI" as="xs:string"
		select="/leg:Legislation/ukm:Metadata/atom:link[@rel = 'http://www.legislation.gov.uk/def/navigation/resources']/@href"/>
	<xsl:variable name="impactURI" as="xs:string?"
		select="/leg:Legislation/ukm:Metadata/atom:link[@rel = 'http://www.legislation.gov.uk/def/navigation/impacts']/@href"/>
	<xsl:variable name="legislationIdURI" select="/leg:Legislation/@IdURI"/>
	<xsl:variable name="enURI" as="xs:string?"
		select="/leg:Legislation/ukm:Metadata/atom:link[@rel = 'http://www.legislation.gov.uk/def/navigation/notes/toc' and not(@hreflang = 'cy')]/@href | /leg:Legislation/ukm:Metadata/atom:link[@rel = 'http://www.legislation.gov.uk/def/navigation/executive-note/toc']/@href"/>
	<xsl:variable name="emURI" as="xs:string?"
		select="/leg:Legislation/ukm:Metadata/atom:link[@rel = 'http://www.legislation.gov.uk/def/navigation/memorandum/toc' and not(@hreflang = 'cy')]/@href"/>
	<xsl:variable name="pnURI" as="xs:string?"
		select="/leg:Legislation/ukm:Metadata/atom:link[@rel = 'http://www.legislation.gov.uk/def/navigation/policy-note/toc']/@href"/>
	<xsl:variable name="IsEnAvailable" as="xs:boolean" select="exists($enURI)"/>
	<xsl:variable name="IsEmAvailable" as="xs:boolean" select="exists($emURI)"/>
	<xsl:variable name="IsPnAvailable" as="xs:boolean" select="exists($pnURI)"/>
	<xsl:variable name="IsMoreResourcesAvailable" as="xs:boolean" select="tso:ShowMoreResources(/)"/>
	<xsl:variable name="IsImpactAssessmentsAvailable" as="xs:boolean" select="exists($impactURI)"/>
	<xsl:variable name="nstMetadata" as="element()"
		select="$g_ndsMetadata/(ukm:SecondaryMetadata | ukm:PrimaryMetadata | ukm:EUMetadata | ukm:BillMetadata)"/>
	<xsl:variable name="paramsDoc" as="document-node()?">
		<xsl:sequence select="
				if (doc-available('input:request-info')) then
					doc('input:request-info')
				else
					()"/>
	</xsl:variable>
	<xsl:variable name="errorSearchingDoc" as="document-node()?">
		<xsl:sequence select="
				if (doc-available('input:error-searching')) then
					doc('input:error-searching')
				else
					()"/>
	</xsl:variable>

	<!-- getting the document type -->
	<xsl:function name="leg:GetDocumentMainType" as="xs:string">
		<xsl:param name="legislation" as="document-node()"/>
		<xsl:sequence select="$g_strDocumentMainType"/>
	</xsl:function>

	<!-- uri Prefix-->
	<xsl:variable name="uriPrefix" as="xs:string">
		<xsl:value-of
			select="tso:GetUriPrefixFromType(leg:GetDocumentMainType(.), /leg:Legislation/ukm:Metadata/(ukm:PrimaryMetadata | ukm:SecondaryMetadata | ukm:EUMetadata | ukm:BillMetadata)/ukm:Year/@Value)"
		/>
	</xsl:variable>
	<xsl:variable name="documentMainType" as="xs:string" select="leg:GetDocumentMainType(.)"/>
	<xsl:variable name="isDraft" as="xs:boolean" select="leg:IsDraft(.)"/>
	<xsl:variable name="isBill" as="xs:boolean" select="leg:IsBill(.)"/>
	<xsl:variable name="scheduleText">
		<xsl:value-of select="
				if ($g_strDocumentType = $g_strEUretained) then
					'Annex'
				else
					'Schedule'"/>
	</xsl:variable>
	<xsl:variable name="schedulesText">
		<xsl:value-of select="
				if ($g_strDocumentType = $g_strEUretained) then
					'Annexes'
				else
					'Schedules'"/>
	</xsl:variable>
	<xsl:variable name="attachmentsText">
		<xsl:value-of select="'Attachments'"/>
	</xsl:variable>
	<xsl:variable name="title">
		<xsl:choose>
			<xsl:when test="$language = 'cy' and count($dctitle) &gt; 1">
				<xsl:value-of select="$dctitle[@xml:lang = 'cy']"/>
			</xsl:when>
			<xsl:when test="$language = 'cy' and count($dctitle) = 1">
				<xsl:value-of select="$dctitle"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$dctitle[not(@xml:lang = 'cy')]"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="date" select="/leg:Legislation/ukm:Metadata/dc:modified"/>

	<!-- [Converstion starts] -->
	<xsl:template match="/">
		<html>
			<head>
				<title>
					<xsl:choose>
						<xsl:when test="$language = 'cy'">
							<xsl:value-of select="$dctitle[@xml:lang = 'cy']"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$dctitle[not(@xml:lang = 'cy')]"/>
						</xsl:otherwise>
					</xsl:choose>
				</title>
				<xsl:apply-templates select="/leg:Legislation/ukm:Metadata" mode="HTMLmetadata"/>
				<xsl:call-template name="TSOOutputAddLegislationStyles"/>				
			</head>

			<body xml:lang="en" dir="ltr" id="leg" about="{$dcIdentifier}" class="browse">
				<div id="layout2" class="legToc">
					<!-- adding quick search  -->
					<xsl:call-template name="TSOOutputQuickSearch"/>
					<!-- adding the title of the legislation-->
					<xsl:call-template name="TSOOutputLegislationTitle"/>
					<!-- breadcrumb 
					<xsl:call-template name="TSOOutputBreadcrumbItems"/>-->
					<!-- Sub Navigation tabs-->
					<xsl:call-template name="TSOOutputSubNavTabs"/>
					<div class="interface"> </div>
					<!--./interface -->
					<!--<div id="tools">
						<div class="section" id="whatVersion">
							<div class="title">
								<h2>Buy Now</h2>
							</div>
						</div>
					</div>-->
					<!--/tools-->
					<div id="buynow-content">
						<xsl:if test="exists($errorSearchingDoc)">
							<div id="errorBar">
								<xsl:choose>
									<xsl:when
										test="$errorSearchingDoc/errorsearching/status-code = '400'">
										<xsl:attribute name="class" select="'error errorMessage'"/>
										<xsl:value-of
											select="leg:TranslateText(string-join($errorSearchingDoc/errorsearching/message, ''))"
										/>
									</xsl:when>
									<xsl:when
										test="$errorSearchingDoc/errorsearching/status-code = '200'">
										<xsl:attribute name="class" select="'success errorMessage'"/>
										<xsl:value-of
											select="leg:TranslateText(string-join($errorSearchingDoc/errorsearching/message, ''))"
										/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:attribute name="class" select="'error errorMessage'"/>
										<xsl:value-of
											select="concat(leg:TranslateText('Please check the form fields which are highlighted in red'), '. ', $errorSearchingDoc/errorsearching/message)"
										/>
									</xsl:otherwise>
								</xsl:choose>
							</div>
						</xsl:if>

						<xsl:if test="not($errorSearchingDoc/errorsearching/status-code = '200')">
							<xsl:call-template name="TSOOutputLegislationContent"/>
						</xsl:if>

						<div class="contentFooter">
							<div class="interface"> </div>
						</div>

						<p class="backToTop">
							<a href="#top">
								<xsl:value-of select="leg:TranslateText('Back to top')"/>
							</a>
						</p>
					</div>
					<!--/content-->
				</div>

				<!--layout2 -->
				<!-- Where all of the Help divs and modal windows are loaded -->
				<h2 class="interfaceOptionsHeader">
					<xsl:value-of select="leg:TranslateText('Options')"/>
					<xsl:text>/</xsl:text>
					<xsl:value-of select="leg:TranslateText('Help')"/>
				</h2>
				<!-- opening options model
				<xsl:call-template name="TSOOutputOpeningOptionsWarning"/> -->
				<!-- help tips -->
				<xsl:call-template name="TSOOutputHelpTips"/>
			</body>
		</html>
	</xsl:template>

	<!-- ========== CSS Styles for Legislation =============-->
	<xsl:template name="TSOOutputAddLegislationStyles">
		<style type="text/css">
      	<xsl:text>/* Legislation stylesheets - load depending on content type */ </xsl:text>
      	<xsl:text>@import "/styles/legislation.css";</xsl:text>
      	<xsl:text>@import "/styles/legislationOverwrites.css";</xsl:text>
      	<xsl:text>/* End of Legislation stylesheets */</xsl:text>
    	</style>
		<xsl:comment>
			[if IE 6]>
				&lt;style type="text/css">
				@import "/styles/IE/ie6LegAdditions.css";
				&lt;/style>
				&lt;
			![endif]
		</xsl:comment>
		<xsl:comment>
			[if IE 7]>
				&lt;style type="text/css">
				@import "/styles/IE/ie7LegAdditions.css";
				&lt;/style>
				&lt;
			![endif]
		</xsl:comment>
	</xsl:template>

	<!-- ========== Standard code for outputing legislation content ========= -->
	<xsl:template name="TSOOutputLegislationContent">
		<div id="viewLegContents"
			xml:lang="{if(contains((/leg:Legislation/ukm:Metadata/dc:identifier)[1],'/cy/')) then 'cy' else 'en'}">
			<xsl:variable name="hasBlockAmends"
				select="exists(/leg:Legislation/(leg:Primary | leg:Secondary | leg:EURetained)//leg:BlockAmendment)"/>
			<div class="LegSnippet" id="viewLegSnippet">
				<xsl:variable name="isbn" select="
						if (exists($nstMetadata/ukm:ISBN/@Value)) then
							tso:formatISBN($nstMetadata/ukm:ISBN/@Value)
						else
							()"/>

				<div class="buynow-page">
					<div>
						<div class="buynow-border">
							<p class="buynow-title">
								<span>Official printed and bound copies of legislation</span>
							</p>
						</div>
						<p>Bound copies of legislation are provided by the official legislation publisher, The Stationery Office Ltd (TSO).</p>
						<p>
							<b>How much does an official printed copy cost?</b>
						</p>
						<p style="margin-top:0%;margin-bottom:2%;">Each copy is printed on request and priced according to page count. TSO will contact you with the price for your copy.</p>
					</div>

					<form action="{$requestInfoDoc/request/request-uri}" method="post">
						<div class="formBlock">
							<input type="hidden" name="title" value="{$title}"/>
							<input type="hidden" name="isbn" value="{$isbn}"/>
							<div class="buynow-border">
								<p style="padding: 0% 0% 2% 0%; font-size: 1.05rem !important;">
									<span>Please send me a price for </span>
									<b>
										<xsl:value-of select="$title"/>
									</b>
									<span> as it was when it was enacted on </span>
									<b>
										<xsl:sequence select="
												if ($date castable as xs:date) then
													format-date($date, '[D1o] [MNn] [Y]', 'en', (), ())
												else
													$date"/>
									</b>
								</p>
							</div>
							<div class="buynow-form">
								<!-- [Name] -->
								<div class="row">
									<div class="searchCol1">
										<label for="name"><b>Your full name </b>(required):</label>
									</div>
									<div class="searchCol2">
										<input class="buynow-name buynow-textbox" type="text"
											id="name" name="name"
											value="{leg:resolve-request-data($paramsDoc//parameters/parameter[name = 'name']/value)}"
											required="required"/>
									</div>
								</div>
								<!-- [Email] -->
								<div class="row">
									<div class="searchCol1">
										<label for="tel"><b>Email address </b>(required):</label>
									</div>
									<div class="searchCol2">
										<input class="buynow-email buynow-textbox" type="email"
											id="email" name="email"
											value="{leg:resolve-request-data($paramsDoc//parameters/parameter[name = 'email']/value)}"
											required="required"/>
									</div>
								</div>

								<!--[Phone]-->
								<div class="row">
									<div class="searchCol1">
										<label for="tel"><b>Telephone </b>(optional):</label>
									</div>
									<div class="searchCol2">
										<input class="buynow-phone buynow-textbox" type="text"
											id="tel" name="tel"
											value="{leg:resolve-request-data($paramsDoc//parameters/parameter[name = 'tel']/value)}"
										/>
									</div>
								</div>

								<!--[Additional Message from User]-->
								<div class="row">
									<div class="searchCol3">
										<label for="message">Any other details that may help us:</label>
									</div>
								</div>
								<div class="row">
									<div class="searchCol3">
										<textarea class="buynow-message buynow-textbox" id="message"
											name="message" maxlength="200"/>
									</div>
								</div>

								<!--[recaptcha]-->
								<!--<div class="g-recaptcha" data-sitekey="'sitekey'" />-->

								<!--[Submit]-->
								<div class="row">
									<div class="submit">
										<button type="button" id="buyNowSubmit"
											class="buynow-submit">Please send me a price</button>
									</div>

									<!--[Cancel]-->
									<div class="submit searchCol2">
										<button type="submit" id="buyNowCancel"
											onclick="window.history.back();" class="buynow-cancel"
											>Cancel and go back</button>
									</div>
								</div>
							</div>
						</div>
					</form>
				</div>
				<!-- add a break -->
				<span class="LegClearFix"/>
			</div>
		</div>
	</xsl:template>

	<!-- title heading of the legislation-->
	<xsl:template name="TSOOutputLegislationTitle">
		<h1 id="pageTitle"
			class="pageTitle{if ($isDraft) then ' draft' else if (leg:IsProposedVersion(.)) then ' proposed' else ''}">
			<xsl:choose>
				<xsl:when test="$dcalternative">
					<span>
						<xsl:value-of select="$dcalternative"/>
					</span>
					<a href="#" class="pageTitleToggleLink">
						<xsl:value-of select="leg:TranslateText('Show full title')"/>
					</a>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$title"/>
				</xsl:otherwise>
			</xsl:choose>
		</h1>
		<xsl:if test="$dcalternative">
			<p class="fullTitle">
				<xsl:value-of select="$title"/>
			</p>
		</xsl:if>
	</xsl:template>

	<!-- Text of tooltip has been put in resource.xml for english and welsh version -->
	<xsl:template name="TSOOutputHelpTips">
		<!-- Help text is moved to resource.xml to have different test for welsh and english -->
		<xsl:if test="(leg:IsTOC() or leg:IsContentTabDisplaying())">
			<div class="help" id="openingOptionsHelp">
				<span class="icon"/>
				<div class="content">
					<a href="#" class="close">
						<img alt="Close" src="/images/chrome/closeIcon.gif"/>
					</a>
					<h3>
						<xsl:value-of select="leg:TranslateText('openingOptionsHelp_head')"/>
					</h3>
					<p>
						<xsl:value-of select="leg:TranslateText('openingOptionsHelp_para')"/>
					</p>
				</div>
			</div>
		</xsl:if>
		<!-- displaying the output help tips for EN/EM tabs -->
		<xsl:call-template name="TSOOutputENsHelpTips"/>
		<xsl:if
			test="exists(/leg:Legislation/ukm:Metadata/ukm:Alternatives/ukm:Alternative) or exists(/leg:Legislation/ukm:Metadata/ukm:CorrectionSlips/ukm:CorrectionSlip)">
			<div class="help" id="moreResourcesHelp">
				<span class="icon"/>
				<div class="content">
					<a href="#" class="close">
						<img alt="Close" src="/images/chrome/closeIcon.gif"/>
					</a>
					<h3>
						<xsl:value-of select="leg:TranslateText('moreResourcesHelp_head')"/>
					</h3>
					<p>
						<xsl:value-of select="leg:TranslateText('moreResourcesHelp_para1')"/>
					</p>
					<ul>
						<li>
							<xsl:value-of
								select="leg:TranslateText('moreResourcesHelp_ul_li_1_part1')"/>
							<xsl:text> </xsl:text>
							<xsl:value-of select="leg:TranslateText(leg:GetCodeSchemaStatus(.))"/>
							<xsl:text> </xsl:text>
							<xsl:value-of
								select="leg:TranslateText('moreResourcesHelp_ul_li_1_part3')"/>
						</li>
						<li>
							<xsl:value-of select="leg:TranslateText('moreResourcesHelp_ul_li_2')"/>
						</li>
					</ul>
					<p/>
					<p>
						<xsl:value-of select="leg:TranslateText('moreResourcesHelp_para2')"/>
					</p>
					<ul>
						<li>
							<xsl:value-of select="leg:TranslateText('moreResourcesHelp_ul2_li_1')"/>
						</li>
						<li>
							<xsl:value-of select="leg:TranslateText('moreResourcesHelp_ul2_li_2')"/>
						</li>
						<li>
							<xsl:value-of select="leg:TranslateText('moreResourcesHelp_ul2_li_3')"/>
						</li>
						<li>
							<xsl:value-of select="leg:TranslateText('moreResourcesHelp_ul2_li_4')"/>
						</li>
					</ul>
				</div>
			</div>
		</xsl:if>
	</xsl:template>

	<xsl:function name="leg:IsContentTabDisplaying" as="xs:boolean">
		<xsl:sequence select="false()"/>
	</xsl:function>

	<xsl:function name="leg:resolve-request-data" as="xs:string?">
		<xsl:param name="string" as="xs:string?"/>
		<xsl:if test="exists($string)">
			<xsl:variable name="removechars" select="replace($string, '”|&lt;|&gt;', '')"/>
			<xsl:variable name="removedoublequotes"
				select="translate($removechars, &quot;&quot;&quot;&quot;, &quot;&quot;)"/>
			<xsl:value-of select="$removedoublequotes"/>
		</xsl:if>
	</xsl:function>

</xsl:stylesheet>
