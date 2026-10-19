import Head from 'next/head'

export default function GeeseDownload() {
  return <>
    <Head><title>Geese — Move your apps together</title><meta name="description" content="Move a group of Mac app windows to another desktop in one click." /></Head>
    <main style={{maxWidth: 640, margin: '80px auto', padding: '0 24px', fontFamily: 'system-ui, sans-serif', lineHeight: 1.6}}>
      <h1 style={{fontSize: 48, marginBottom: 8}}>Geese</h1>
      <p style={{fontSize: 24}}>Move your apps together.</p>
      <p>Choose the apps you take between projects. Click a desktop and Geese brings their windows with you.</p>
      <p><a href="/apps/geese/install/Geese.dmg" style={{display:'inline-block', padding:'12px 20px', background:'#007d89', color:'#fff', borderRadius:10, textDecoration:'none'}}>Download Geese for Mac</a></p>
      <p>Apple silicon · macOS 14 or later · Free</p>
      <h2>Set up once</h2>
      <ol>
        <li>Open the download and drag Geese into Applications.</li>
        <li>Open Geese. This build isn’t Apple-notarized. If macOS blocks it, go to System Settings → Privacy &amp; Security and choose Open Anyway for Geese.</li>
        <li>Allow Geese in Privacy &amp; Security → Accessibility so it can move windows.</li>
      </ol>
      <p>Add apps with +, then choose a desktop. Press Control-Option-Command-G to show or hide Geese. Right-click the menu bar bird for settings.</p>
      <p>Geese checks for updates and asks before installing them. You can also choose Check for Updates from its settings.</p>
      <p>Window movement uses private macOS APIs, tested on macOS 26.7.1. Other versions may behave differently. Minimized and full-screen windows stay where they are.</p>
      <p>App choices and window information stay on your Mac. Update checks contact this website; no window titles or app selections are sent.</p>
    </main>
  </>
}
