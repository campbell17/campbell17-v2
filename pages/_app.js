import '../styles/global.scss';
import Router from 'next/router';
import NProgress from 'nprogress'; //nprogress module
import '../styles/nprogress.css'; //styles of nprogress

//Route Events. 
Router.events.on('routeChangeStart', () => NProgress.start()); 
Router.events.on('routeChangeComplete', () => NProgress.done()); 
Router.events.on('routeChangeError', () => NProgress.done());

// NProgress.configure({ showSpinner: false })

export default function App({ Component, pageProps }){
  return <Component {...pageProps} />;
}