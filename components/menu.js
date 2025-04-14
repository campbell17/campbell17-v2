import Image from 'next/image';
import Link from 'next/link';
import { useRouter } from 'next/router';

const menu = [
  { title: 'about', path: '/' },
  { title: 'projects', path: '/projects' },
  { title: 'Journal', path: '/posts' },
]

export const Menu = () => {
  const router = useRouter();

  return (
    <header role="banner" className="content">
        <div className="nav">
          <div className="logo inner">
            <Link href="/">
              <Image src="/images/logo-sm.png" width={64} height={64} alt="Site logo" />
            </Link>
          </div>        
          <nav role="navigation">
            <Link href="/" className={router.pathname == "/" ? "nav-link active" : "nav-link"}>about</Link>
            <span className="nav-break border-color">/</span>
            <Link href="/projects" className={router.pathname.includes("/projects") ? "nav-link active" : "nav-link"}>projects</Link>
            <span className="nav-break border-color">/</span>
            <Link href="/journal" className={router.pathname.includes("/journal") ? "nav-link active" : "nav-link"}>journal</Link>
          </nav>
        </div>
    </header>
  );
}