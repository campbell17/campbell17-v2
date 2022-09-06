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
            <Link href="mailto:timcampbell@hey.com?subject=Work%20Inquiry%3A%20Let's%20chat..."><a className="cta">Work Inquiries</a></Link>
            <Link href="https://www.instagram.com/campbell1117"><a className="cta">Instagram</a></Link>
            <Link href="https://www.twitter.com/timcampbell17"><a className="cta">Twitter</a></Link>
          </div>
        </div>  
        <div className="content title-block copy">
          <p>&copy; Tim Campbell 2003-2022 
            <span>&bull;</span>
            email: timcampbell at hey dot com
          </p>  
        </div>
      </div>
    </footer> 
  )
}