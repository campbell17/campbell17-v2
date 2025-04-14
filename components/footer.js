import Link from 'next/link';
import styles from './layout.module.scss';

export default function Footer() {
  return (
    <footer>
      <div className={styles.container}>
        <div className="content title-block">
          <h2 className="page-title">Get in touch</h2>
          <p>Wanna chat? Hit me up:</p>
        </div>
        <div className="content">
          <div className="flex flex-a-start flex-j-start">
            <Link
              href="mailto:timcampbell@hey.com?subject=Work%20Inquiry%3A%20Let's%20chat..."
              className="cta">Work Inquiries</Link>
            <Link href="https://www.instagram.com/campbell1117" className="cta">Instagram</Link>
            <Link href="https://www.twitter.com/timcampbell17" className="cta">Twitter</Link>
          </div>
        </div>  
        <div className="content" style={{ padding: "2em 0" }}>
          <p>...or subscribe to get humorous and pithy short stories piped to your inbox:</p>
          <iframe src="https://campbellseventeen.substack.com/embed" width="100%" height="220" style={{ border: "1px solid #ddd", backgroundColor: 'white', frameborder: 0, scrolling: "no" }}></iframe>
        </div>
        <div className="content title-block copy">
          <p>&copy; Tim Campbell 2003-2023 
            <span>&bull;</span>
            email: timcampbell at hey dot com
          </p>  
        </div>
      </div>
    </footer> 
  )
}