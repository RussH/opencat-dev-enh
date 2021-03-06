<?php /* $Id: Login.tpl 3530 2007-11-09 18:28:10Z brian $ */ ?>
<?php 
 //modified by Allan, 2/20/2012
 $site_title = 'CATS - Login';
 $candidate_portal = false;

 if(isset($_GET['portal']) || isset($_GET['reloginVars'])) { 
    $portal = $_GET['portal'];
    if($portal == '')
    	$portal = $_GET['reloginVars'];
    if($portal == 'candidates' || substr(urldecode($portal),0,17)=='portal=candidates') {
    	$candidate_portal = true;
    	$site_title = 'ClearRoad IT Candidate Portal - Login';
    }
 } 
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
    <head>
        <title><?php echo($site_title);?></title>
        <meta http-equiv="Content-Type" content="text/html; charset=<?php echo(HTML_ENCODING); ?>" />
        <style type="text/css" media="all">@import "modules/login/login.css";</style>
        <script type="text/javascript" src="js/lib.js"></script>
        <script type="text/javascript" src="modules/login/validator.js"></script>
        <script type="text/javascript" src="js/submodal/subModal.js"></script>
    </head>

    <body>
    <!-- CATS_LOGIN -->
    <?php TemplateUtility::printPopupContainer(); ?>
        <?php if($candidate_portal == false) { ?>
            <div id="headerBlock">
                <span id="mainLogo">C&nbsp;A&nbsp;T&nbsp;S</span><br />
                <span id="subMainLogo">Applicant Tracking System</span>
            </div>
        <?php } else { ?>
            <div id="headerBlock">
                <span id="mainLogo"><img src="<?=CANDIDATE_PORTAL_LOGO?>" border="0" /></span><br />
                <span id="subMainLogo"><?=CANDIDATE_PORTAL_SUBTEXT?></span>
            </div>        
        <?php } ?>
        <div id="contents">
            <div id="login">
                <?php if (!empty($this->message)): ?>
                    <div>
                        <?php if ($this->messageSuccess): ?>
                            <p class="success"><?php $this->_($this->message); ?><br /></p>
                        <?php else: ?>
                            <p class="failure"><?php $this->_($this->message); ?><br /></p>
                        <?php endif; ?>
                    </div>
                <?php endif; ?>

                <div id="loginText">
                    <div class="ctr">
                        <img src="images/folder1_locked.jpg" width="64" height="64" alt="security" />
                    </div>
                    <br />
                    <?php if($candidate_portal == false) { ?>
                        <span>Welcome to CATS!</span><br />
                        <span style="font-size: 10px;">Version <?php echo(CATSUtility::getVersion()); ?></span>
					<?php } else { ?>
                        <span>Welcome to Clear Road IT</span><br />
                        <span style="font-size: 10px;">Candidate Portal</span>                    
                    <?php } ?>
                    <?php if (ENABLE_DEMO_MODE && !($this->siteName != '' && $this->siteName != 'choose') || ($this->siteName == 'demo')): ?>
                        <br /><br />
                        <?php if ($this->aspMode): ?>
                            <a href="javascript:void(0);" onclick="demoLogin(); return false;">Login to Demo Account</a><br />
                            <br />
                            <a href="<?php echo(CATSUtility::getIndexName()); ?>?m=asp&amp;a=forgotLogin&amp;p=0">Forgot Login Information?</a>
                        <?php else: ?>
                            <a href="javascript:void(0);" onclick="demoLogin(); return false;">Login to Demo Account</a><br />
                        <?php endif; ?>
                    <?php elseif ($this->aspMode): ?>
                        <br /><br />
                        <a href="<?php echo(CATSUtility::getIndexName()); ?>?m=asp&amp;a=forgotLogin&amp;p=0">Forgot Login Information?</a>
                    <?php endif; ?>
                </div>

                <div id="formBlock">
                    <?php if($candidate_portal == false) { ?>
                    	<img src="images/login2.jpg" alt="Login" />
                    <?php } else { ?>
                    	<img src="images/login3.jpg" alt="Login" />
                    <?php } ?>
                    <form name="loginForm" id="loginForm" action="<?php echo(CATSUtility::getIndexName()); ?>?m=login&amp;a=attemptLogin<?php if ($this->reloginVars != ''): ?>&amp;reloginVars=<?php echo($this->reloginVars); ?><?php endif; ?>" method="post" onsubmit="return checkLoginForm(document.loginForm);" autocomplete="off">
                        <div id="subFormBlock">
                            <?php if ($this->siteName != '' && $this->siteName != 'choose'): ?>
                                <?php if ($this->siteNameFull == 'error'): ?>
                                    <label>This site does not exist. Please check the URL and try again.</label>
                                    <br />
                                    <br />
                                <?php else: ?>
                                    <label><?php $this->_($this->siteNameFull); ?></label>
                                    <br />
                                    <br />
                                <?php endif; ?>
                            <?php endif; ?>

                            <?php if ($this->aspMode): ?>
                                <?php if ($this->siteName == 'choose' || ($this->aspMode && $this->siteName == '')): ?>
                                    <label id="siteNameLabel" for="siteName">Company Identifier</label><br />
                                    <input name="siteName" id="siteName" class="login-input-box" />
                                    <br />
                                <?php elseif($this->siteName != ''): ?>
                                    <input type="hidden" name="siteName" value="<?php $this->_($this->siteName); ?>">
                                <?php endif; ?>
                            <?php endif; ?>

                            <?php if ($this->siteNameFull != 'error'): ?>
                                <label id="usernameLabel" for="username">Email / Username</label><br />
                                <input name="username" id="username" class="login-input-box" value="<?php if (isset($this->username)) $this->_($this->username); ?>" />
                                <br />

                                <label id="passwordLabel" for="password">Password</label><br />
                                <input type="password" name="password" id="password" class="login-input-box" />
                                <br />

                                <input type="submit" class="button" value="Login" />
                                <input type="reset"  id="reset" name="reset"  class="button" value="Reset" />
                                </form>
                                <br /><br />
                                <?php echo($this->forgot_msg); ?>                                
                                <a href="javascript:document.getElementById('div_forgot').style.display='block'; void(0);" style="display:block">Forgot Login Information</a>
                                <div id="div_forgot" style="display:none">
                                	<form name="loginForm2" id="loginForm2" action="<?php echo(CATSUtility::getIndexName()); ?>?m=login<?php if($candidate_portal==true) { ?>&amp;portal=candidates<?php } ?>&amp;a=forgotLogin" method="post"  autocomplete="off">
                                        <label id="emailLabel" for="email">Email / Username&nbsp;:</label>
                                        <input name="username" id="username" class="login-input-box" value="" /><br />
                                        <input type="submit" class="button" value="Send Password" />
                                    </form>
                                </div>
                            <?php else: ?>
                                <br />
                                <?php if ($this->aspMode): ?>
                                    <a href="<?php echo(CATSUtility::getIndexName()); ?>?m=asp&amp;a=createsite&amp;p=0">Create Free Trial Site</a><br />
                                    <a href="<?php echo(CATSUtility::getIndexName()); ?>?m=asp&amp;a=forgotLogin&amp;p=0">Forgot Login Information</a>
                                <?php else: ?>
                                    <a href="javascript:void(0);" onclick="demoLogin(); return false;">Login to Demo Account</a><br />
                                <?php endif; ?>
                            <?php endif; ?>
                            <br /><br />
                        </div>
                    <!-- </form> -->
                </div>
                <div style="clear: both;"></div>
            </div>
            <br />

            <script type="text/javascript">
                <?php if ($this->siteNameFull != 'error'): ?>
                    document.loginForm.username.focus();

                    function demoLogin()
                    {
                        document.getElementById('username').value = '<?php echo(DEMO_LOGIN); ?>';
                        document.getElementById('password').value = '<?php echo(DEMO_PASSWORD); ?>';
                        document.getElementById('loginForm').submit();
                    }
                    function defaultLogin()
                    {
                        document.getElementById('username').value = 'admin';
                        document.getElementById('password').value = 'cats';
                        document.getElementById('loginForm').submit();
                    }
                <?php endif; ?>
                <?php if (isset($_GET['defaultlogin'])): ?>
                    defaultLogin();
                <?php endif; ?>
            </script>

            <div id="footerBlock">
                <?php 
                    /* THE MODIFICATION OF THE COPYRIGHT AND 'Powered by CATS' LINES IS NOT ALLOWED
                       BY THE TERMS OF THE CPL FOR CATS OPEN SOURCE EDITION.
                    
                         II) The following copyright notice must be retained and clearly legible
                         at the bottom of every rendered HTML document: Copyright (C) 2005 - 2007
                         Cognizo Technologies, Inc. All rights reserved.
                    
                         III) The "Powered by CATS" text or logo must be retained and clearly
                         legible on every rendered HTML document. The logo, or the text
                         "CATS", must be a hyperlink to the CATS Project website, currently
                         http://www.catsone.com/.
                   */
                ?>
                <?php if($candidate_portal == false) { ?>
                    <span class="footerCopyright"><?php echo(COPYRIGHT_HTML); ?></span>
                    <div>Powered by <a href="http://www.catsone.com/"><strong>CATS</strong></a>.</div>
                <?php } ?>
            </div>
        </div>
        <script type="text/javascript">
            initPopUp();
        </script>
        <?php TemplateUtility::printCookieTester(); ?>
    </body>
</html>
