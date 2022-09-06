import styles from './masthead.module.scss'

export default function Masthead(props) {
  return (
    <section>
      <h1 className={styles.title}>{props.title}</h1>
      <p>{props.subtitle}</p>
      {props.children}
    </section>
  )
}