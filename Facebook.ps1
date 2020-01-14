$startDate = [system.datetime]::parse("1/1/2020");

function LoginFacebook($username, $password)
{    
    $Browser = "Firefox";

    $userPath = $env:USERPROFILE;
    $global:scriptpath = "$userPath\OneDrive\My Scripts\Fantasy"
    cd $global:scriptpath;
    $global:commonscriptpath = "$userPath\OneDrive\My Scripts\Common"
    $global:commondllspath = "$userPath\OneDrive\My Scripts\Dlls"

    $Selenium = Get-Selenium $Browser $true;

    $url = "https://www.facebook.com"

    $Selenium.Navigate().GoToUrl($url)

    Start-Sleep 2

    $tbusername = $Selenium.FindElementByCssSelector('input[id="email"]')

    if (!$tbusername)
    {
        $tbusername = $Selenium.FindElementByCssSelector('input[name="email"]')
    }

    $tbusername.SendKeys($userName)

    $tbpassword = $Selenium.FindElementByCssSelector('input[id="pass"]')

    if (!$tbpassword)
    {
        $tbpassword = $Selenium.FindElementByCssSelector('input[name="pass"]')
    }

    $tbpassword.SendKeys($password);

    $btnLogIn = $Selenium.FindElementByCssSelector('input[type="submit"]')

    if (!$btnLogIn)
    {
        $btnLogIn = $Selenium.FindElementByCssSelector('button[type="submit"]')
    }

    $btnLogIn.click();

    Start-Sleep 2;

    #go to the user homepage...
    $homelink = $Selenium.FindElementByCssSelector('a[title="Profile"]')
    $homelink.click();

    $ht = new-object System.Collections.Hashtable;

    #load the date
    $tdate = get-content "postdate";

    if ($tdate)
    {
        $startdate = [System.DateTime]::parse($tdate);
    }
    else
    {
        
    }

    $started = $false;

    $yearBtn = $null

    while ($true)
    {   
        #go to end of page...
        $selenium.executeScript("window.scrollTo(0, document.body.scrollHeight)");

        start-sleep 2;

        if(!$started)
        {
            #jump to the start date...
            $uiButtons = $Selenium.FindElementsByCssSelector("a[class*='uiSelectorButton']")

            foreach($uiB in $uiButtons)
            {
                if ($uiB.Text -eq [datetime]::Now.Year)
                {
                    $uiB.click();
                    $yearBtn = $uiB;

                    #find all the options...
                    $uiOptions = $Selenium.FindElementsByCssSelector("li[class*='uiMenuItem']")

                    foreach($uiO in $uiOptions)
                    {
                        if ($uiO.Text -eq $startdate.Year)
                        {
                            $uiO.Click();
                        }
                    }
                }
            }
        }

        #get all the posts...
        $postLinks = $Selenium.FindElementsByCssSelector('a[aria-label="Story options"]')
    
        foreach($postLink in $postLinks)
        {
            if ($ht.containskey($postlink.GetAttribute("id")))
            {
                continue;
            }

            $postLink.click();

            start-sleep 2;

            #only cancel shows up...
            $cancelLinks = $Selenium.FindElementsByCssSelector('a[action="cancel"]')

            foreach($cancelLink in $cancelLinks)
            {
                $cancelLink.click();

                #force refresh...
                $count = 21;
            }

            #delete it...
            $deleteLinks = $Selenium.FindElementsByCssSelector('a[data-feed-option-name="FeedDeleteOption"]')

            foreach($deletelink in $deletelinks)
            {
                if ($deleteLink.displayed)
                {
                    $deleteLink.click();
                }
            }

            #go no matter what...
            $confirm = $Selenium.FindElementsByCssSelector('button[class*="layerConfirm"]')

            foreach($c in $confirm)
            {
                $confirm.click();
            }

            $hideLinks = $Selenium.FindElementsByCssSelector('a[data-feed-option-name="HIDE_FROM_TIMELINE"]')

            if ($hideLinks.count -gt 0)
            {
                $ht.Add($postlink.GetAttribute("id"), $postlink.GetAttribute("id"));
            }

            <#
            #hide it...
            

            foreach($deletelink in $hideLinks)
            {
                $deleteLink.click();

                $confirm = $Selenium.FindElementsByCssSelector('button[class*="layerConfirm"]')

                foreach($c in $confirm)
                {
                    $confirm.click();
                }
            }
            #>

        }
    }


    $strcookie = "";

    foreach($cookie in $Selenium.Manage().Cookies.AllCookies)
    {
        $strcookie += $cookie.name + "=" + $cookie.value + "; "
    }

    $global:cookie = $strcookie;

    write-host "Saving cookie";

    remove-item "logincookie.txt";
    add-content "logincookie.txt" $strcookie;

    Stop-Selenium;   
}


function GetPosts()
{
}

function DeletePost($post)
{
    
}

$userPath = $env:USERPROFILE;

$global:scriptpath = "$userPath\OneDrive\My Scripts\Facebook"

cd $global:scriptpath;

$global:commonscriptpath = "$userPath\OneDrive\My Scripts\Common"

#add in the functions from the Util scriptsg
. "$global:commonscriptpath\Util.ps1"
. "$global:commonscriptpath\Classes.ps1"
. "$global:commonscriptpath\HttpHelper.ps1"
. "$global:commonscriptpath\Selenium.ps1"

$fb = LoginFacebook "youremail" "yourpassword";

$posts = GetPosts;

foreach($post in $posts)
{
    DeletePost $post;
}