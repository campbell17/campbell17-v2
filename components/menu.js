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
              <a>
                <Image src="/images/logo-sm.png" width={60} height={60} alt="Site logo" />
              </a>
            </Link>
          </div>        
          <nav role="navigation">
            <Link href="/"><a className={router.pathname == "/" ? "nav-link active" : "nav-link"}>about</a></Link>
            <span className="border-color">/</span>
            <Link href="/projects"><a className={router.pathname.includes("/projects") ? "nav-link active" : "nav-link"}>projects</a></Link>
            <span className="border-color">/</span>
            <Link href="/journal"><a className={router.pathname.includes("/journal") ? "nav-link active" : "nav-link"}>journal</a></Link>
          </nav>
        </div>
    </header>
  );
}